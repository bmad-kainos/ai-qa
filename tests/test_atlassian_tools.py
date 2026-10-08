import importlib.util
import io
import sys
import types
import unittest
from contextlib import redirect_stderr, redirect_stdout
from pathlib import Path
from unittest import mock

TOOLS = Path(__file__).resolve().parents[1] / ".github/ai-qa/framework/templates/atlassian-tools"


class FakeResponse:
    def __init__(self, payload=None, status_code=200):
        self.payload = payload if payload is not None else {}
        self.status_code = status_code
        self.ok = status_code < 400

    def json(self):
        return self.payload

    def raise_for_status(self):
        if not self.ok:
            raise RuntimeError(self.status_code)


def load(script, **env):
    """Import a script fresh with a fake requests/dotenv, so no dependencies or network are needed."""
    fake_requests = types.SimpleNamespace(
        get=mock.Mock(), post=mock.Mock(), put=mock.Mock(), RequestException=RuntimeError,
    )
    fake_dotenv = types.SimpleNamespace(load_dotenv=lambda *a, **k: None)
    with mock.patch.dict(sys.modules, {"requests": fake_requests, "dotenv": fake_dotenv}), \
            mock.patch.dict("os.environ", env, clear=True):
        spec = importlib.util.spec_from_file_location(f"{script}_under_test", TOOLS / f"{script}.py")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
    return module


CLOUD = {"ATLASSIAN_DEPLOYMENT": "cloud", "ATLASSIAN_EMAIL": "a@example.com", "ATLASSIAN_API_TOKEN": "tok"}


def run(fn, *args):
    out, err = io.StringIO(), io.StringIO()
    with redirect_stdout(out), redirect_stderr(err):
        try:
            fn(*args)
            code = 0
        except SystemExit as exc:
            code = exc.code
    return code, out.getvalue(), err.getvalue()


class JiraToolTests(unittest.TestCase):
    def test_rejects_http_and_untrusted_hosts_before_sending_credentials(self):
        for env in (
            {"JIRA_BASE_URL": "http://jira.example.com", "JIRA_PAT": "x"},
            {"JIRA_BASE_URL": "https://evil.example.com", **CLOUD},
            {"JIRA_BASE_URL": "https://jira.example.com", "JIRA_PAT": "x", "ATLASSIAN_TRUSTED_HOSTS": "other.example.com"},
        ):
            tool = load("jira_tool", **env)
            code, _, _ = run(tool.post_comment, "PROJ-1", "hi")
            self.assertEqual(code, 1, env)
            tool.requests.post.assert_not_called()

    def test_server_uses_v2_bearer_and_string_body(self):
        tool = load("jira_tool", JIRA_BASE_URL="https://jira.example.com", JIRA_PAT="secret")
        tool.requests.post.return_value = FakeResponse({"id": "9"})
        code, out, _ = run(tool.post_comment, "PROJ-1", "hello")
        self.assertEqual(code, 0)
        args, kwargs = tool.requests.post.call_args
        self.assertEqual(args[0], "https://jira.example.com/rest/api/2/issue/PROJ-1/comment")
        self.assertEqual(kwargs["headers"]["Authorization"], "Bearer secret")
        self.assertEqual(kwargs["json"], {"body": "hello"})
        self.assertNotIn("secret", out)

    def test_cloud_uses_v3_basic_and_adf_body(self):
        tool = load("jira_tool", JIRA_BASE_URL="https://example.atlassian.net", **CLOUD)
        tool.requests.post.return_value = FakeResponse({"id": "9"})
        run(tool.post_comment, "PROJ-1", "line one\n\nline two")
        args, kwargs = tool.requests.post.call_args
        self.assertEqual(args[0], "https://example.atlassian.net/rest/api/3/issue/PROJ-1/comment")
        self.assertTrue(kwargs["headers"]["Authorization"].startswith("Basic "))
        body = kwargs["json"]["body"]
        self.assertEqual(body["type"], "doc")
        self.assertEqual([p["content"][0]["text"] for p in body["content"]], ["line one", "line two"])

    def test_fetch_reports_updated_acceptance_criteria_and_paginates_comments(self):
        tool = load("jira_tool", JIRA_BASE_URL="https://example.atlassian.net", **CLOUD)
        adf = {"type": "doc", "content": [{"type": "paragraph", "content": [{"type": "text", "text": "Must pass"}]}]}

        def get(url, **kwargs):
            if url.endswith("/field"):
                return FakeResponse([{"id": "customfield_1", "name": "Acceptance Criteria"}])
            if url.endswith("/comment"):
                start = kwargs["params"]["startAt"]
                batch = [{"id": str(n), "body": "c", "author": {"displayName": "A"}, "created": "2026-01-01"}
                         for n in range(start, min(start + 50, 120))]
                return FakeResponse({"comments": batch, "total": 120})
            return FakeResponse({"fields": {"summary": "S", "updated": "2026-02-02T00:00:00.000+0000",
                                            "customfield_1": adf, "description": adf}})

        tool.requests.get.side_effect = get
        code, out, _ = run(tool.fetch_ticket, "PROJ-1")
        self.assertEqual(code, 0)
        self.assertIn("2026-02-02", out)
        self.assertIn("Must pass", out)
        self.assertIn("COMMENTS (120 of 120)", out)
        self.assertNotIn("WARNING", out)

    def test_missing_acceptance_criteria_is_reported_unknown(self):
        tool = load("jira_tool", JIRA_BASE_URL="https://jira.example.com", JIRA_PAT="x")

        def get(url, **kwargs):
            if url.endswith("/field"):
                return FakeResponse([])
            if url.endswith("/comment"):
                return FakeResponse({"comments": [], "total": 0})
            return FakeResponse({"fields": {"summary": "S"}})

        tool.requests.get.side_effect = get
        _, out, _ = run(tool.fetch_ticket, "PROJ-1")
        self.assertIn("unknown (no populated acceptance-criteria field", out)


class ConfluenceToolTests(unittest.TestCase):
    def setUp(self):
        self.tool = load("confluence_tool", CONFLUENCE_BASE_URL="https://wiki.example.com", CONFLUENCE_PAT="x")

    def test_rejects_http_and_untrusted_cloud_hosts(self):
        for env in (
            {"CONFLUENCE_BASE_URL": "http://wiki.example.com", "CONFLUENCE_PAT": "x"},
            {"CONFLUENCE_BASE_URL": "https://evil.example.com/wiki", **CLOUD},
        ):
            tool = load("confluence_tool", **env)
            code, _, _ = run(tool.get_page, "1")
            self.assertEqual(code, 1, env)
            tool.requests.get.assert_not_called()

    def test_text_is_escaped(self):
        self.assertEqual(self.tool._md_to_confluence("R&D and x < 5 <b>"), "<p>R&amp;D and x &lt; 5 &lt;b&gt;</p>")

    def test_cdata_terminator_is_split(self):
        out = self.tool._md_to_confluence("```\na ]]> b\n```")
        self.assertIn("a ]]]]><![CDATA[> b", out)

    def test_links_are_validated_and_escaped(self):
        out = self.tool._md_to_confluence('[ok](https://example.com/a?x=1&y="2") [bad](javascript:alert(1)) a_b_c')
        self.assertIn('<a href="https://example.com/a?x=1&amp;y=&quot;2&quot;">ok</a>', out)
        self.assertNotIn("javascript", out)
        self.assertIn("bad", out)
        self.assertIn("a_b_c", out)

    def test_h3_is_blue_and_code_spans_are_protected(self):
        out = self.tool._md_to_confluence("### Title\n`a*b*c` **bold**")
        self.assertIn("rgb(0,82,204)", out)
        self.assertIn("<code>a*b*c</code>", out)
        self.assertIn("<strong>bold</strong>", out)

    def test_get_prints_the_whole_body(self):
        body = "x" * 5000
        self.tool.requests.get.return_value = FakeResponse(
            {"title": "T", "space": {"key": "S"}, "version": {"number": 3}, "body": {"storage": {"value": body}}})
        _, out, _ = run(self.tool.get_page, "1")
        self.assertIn(body, out)

    def test_append_puts_next_version_with_existing_body(self):
        self.tool.requests.get.return_value = FakeResponse(
            {"title": "T", "space": {"key": "S"}, "version": {"number": 3}, "body": {"storage": {"value": "<p>old</p>"}}})
        self.tool.requests.put.return_value = FakeResponse({})
        code, _, _ = run(self.tool.append_to_page, "1", "new")
        self.assertEqual(code, 0)
        payload = self.tool.requests.put.call_args.kwargs["json"]
        self.assertEqual(payload["version"]["number"], 4)
        self.assertTrue(payload["body"]["storage"]["value"].startswith("<p>old</p>"))
        self.assertIn("<p>new</p>", payload["body"]["storage"]["value"])


if __name__ == "__main__":
    unittest.main()
