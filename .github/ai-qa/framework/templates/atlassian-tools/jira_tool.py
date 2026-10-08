#!/usr/bin/env python3
"""
Jira CLI Tool (no-MCP fallback)
===============================
Fetch ticket details and post or edit comments on Jira Cloud (REST v3, ADF)
or Server/Data Center (REST v2, wiki markup).

Usage:
    python jira_tool.py fetch PROJ-123
    python jira_tool.py comment PROJ-123 "Your comment text here"
    python jira_tool.py comment PROJ-123 --file path/to/comment.md
    python jira_tool.py edit PROJ-123 <comment-id> --file path/to/comment.md

Configuration:
    Copy .env.example to .env next to this script and fill in your values.
    Never commit .env to version control.
"""

from __future__ import annotations

import argparse
import base64
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlparse

import requests
from dotenv import load_dotenv

try:
    import truststore
    truststore.inject_into_ssl()  # Use the operating system trust store
except ImportError:
    pass

load_dotenv(Path(__file__).parent / ".env")

JIRA_BASE_URL = os.environ.get("JIRA_BASE_URL", "").rstrip("/")
DEPLOYMENT = os.environ.get("ATLASSIAN_DEPLOYMENT", "server").strip().lower()
JIRA_PAT = os.environ.get("JIRA_PAT", "")
ATLASSIAN_EMAIL = os.environ.get("ATLASSIAN_EMAIL", "")
ATLASSIAN_API_TOKEN = os.environ.get("ATLASSIAN_API_TOKEN", "")
AC_FIELD_OVERRIDE = os.environ.get("JIRA_ACCEPTANCE_CRITERIA_FIELD", "").strip()
TRUSTED_HOSTS = {h.strip().lower() for h in os.environ.get("ATLASSIAN_TRUSTED_HOSTS", "").split(",") if h.strip()}

API_VERSION = "3" if DEPLOYMENT == "cloud" else "2"
BASE_FIELDS = ["summary", "description", "status", "issuetype", "priority", "assignee",
               "reporter", "labels", "subtasks", "issuelinks", "updated"]
COMMENT_PAGE_SIZE = 50
MAX_COMMENT_PAGES = 20


def _fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def _base() -> str:
    """Return the base URL, refusing anything that could leak credentials."""
    if DEPLOYMENT not in ("cloud", "server"):
        _fail("ATLASSIAN_DEPLOYMENT must be 'cloud' or 'server'.")
    if not JIRA_BASE_URL:
        _fail("JIRA_BASE_URL is not set. Check your .env file.")
    parsed = urlparse(JIRA_BASE_URL)
    host = (parsed.hostname or "").lower()
    if parsed.scheme != "https" or not host or parsed.username or parsed.password:
        _fail("JIRA_BASE_URL must be an https:// URL without embedded credentials.")
    allowed = host in TRUSTED_HOSTS or (DEPLOYMENT == "cloud" and host.endswith(".atlassian.net"))
    if (DEPLOYMENT == "cloud" or TRUSTED_HOSTS) and not allowed:
        _fail(f"Host '{host}' is not trusted. Use *.atlassian.net or list it in ATLASSIAN_TRUSTED_HOSTS.")
    return JIRA_BASE_URL


def _get_headers() -> dict:
    _base()
    if DEPLOYMENT == "cloud":
        if not (ATLASSIAN_EMAIL and ATLASSIAN_API_TOKEN):
            _fail("ATLASSIAN_EMAIL and ATLASSIAN_API_TOKEN must be set for Cloud. Check your .env file.")
        raw = f"{ATLASSIAN_EMAIL}:{ATLASSIAN_API_TOKEN}".encode("utf-8")
        authorization = "Basic " + base64.b64encode(raw).decode("ascii")
    else:
        if not JIRA_PAT:
            _fail("JIRA_PAT is not set. Check your .env file.")
        authorization = f"Bearer {JIRA_PAT}"
    return {
        "Authorization": authorization,
        "Content-Type": "application/json",
        "Accept": "application/json",
    }


def _get_ssl_verify() -> bool | str:
    """Use REQUESTS_CA_BUNDLE if explicitly set, otherwise let truststore handle it."""
    cert_path = os.environ.get("REQUESTS_CA_BUNDLE")
    if cert_path and Path(cert_path).exists():
        return cert_path
    return True


def _request(method: str, path: str, not_found: str, **kwargs):
    response = getattr(requests, method)(
        f"{_base()}/rest/api/{API_VERSION}{path}", headers=_get_headers(),
        verify=_get_ssl_verify(), timeout=30, **kwargs,
    )
    if response.status_code == 404:
        _fail(not_found)
    if response.status_code in (401, 403):
        _fail(f"HTTP {response.status_code}. Check your credentials and permissions in .env.")
    response.raise_for_status()
    return response


# ---------------------------------------------------------------------------
# Content formats: Cloud uses ADF, Server/DC uses wiki markup strings
# ---------------------------------------------------------------------------

_BLOCKS = {"paragraph", "heading", "codeBlock", "blockquote", "tableRow", "rule"}


def _adf_to_text(node) -> str:
    """Flatten an ADF document (or any Jira field value) to readable text."""
    if node is None:
        return ""
    if isinstance(node, str):
        return node
    if isinstance(node, list):
        return "".join(_adf_to_text(n) for n in node)
    if not isinstance(node, dict):
        return str(node)
    kind = node.get("type")
    if kind == "text":
        return node.get("text", "")
    if kind == "hardBreak":
        return "\n"
    if kind == "mention":
        return node.get("attrs", {}).get("text", "")
    inner = _adf_to_text(node.get("content"))
    if kind == "listItem":
        return "- " + inner.rstrip("\n") + "\n"
    if kind in _BLOCKS:
        return inner.rstrip("\n") + "\n"
    if kind is None and ("value" in node or "name" in node):
        return str(node.get("value", node.get("name")))
    return inner


def _text_to_body(text: str):
    """Build the comment body for the configured deployment."""
    if DEPLOYMENT != "cloud":
        return text
    paragraphs = [
        {"type": "paragraph", "content": [{"type": "text", "text": line}]}
        for line in text.splitlines() if line.strip()
    ]
    return {"type": "doc", "version": 1, "content": paragraphs}


# ---------------------------------------------------------------------------
# Read
# ---------------------------------------------------------------------------

def _acceptance_criteria_fields() -> list[str]:
    """Return configured or discovered acceptance-criteria field IDs (may be empty)."""
    if AC_FIELD_OVERRIDE:
        return [AC_FIELD_OVERRIDE]
    try:
        response = _request("get", "/field", "Field list not found.")
        return [f["id"] for f in response.json() if "acceptance criteria" in f.get("name", "").lower()]
    except (SystemExit, requests.RequestException):
        return []


def _fetch_comments(ticket_id: str) -> tuple[list, int, bool]:
    """Page through all comments; return (comments, total, complete)."""
    collected: list = []
    total = 0
    start = 0
    for _ in range(MAX_COMMENT_PAGES):
        data = _request(
            "get", f"/issue/{ticket_id}/comment", f"Ticket {ticket_id} not found.",
            params={"startAt": start, "maxResults": COMMENT_PAGE_SIZE},
        ).json()
        page = data.get("comments", [])
        collected.extend(page)
        total = data.get("total", len(collected))
        start += len(page)
        if not page or start >= total:
            break
    return collected, total, len(collected) >= total


def fetch_ticket(ticket_id: str) -> None:
    """Fetch and display ticket details, acceptance criteria and all comments."""
    ac_fields = _acceptance_criteria_fields()
    fields = ",".join(BASE_FIELDS + ac_fields)
    response = _request("get", f"/issue/{ticket_id}", f"Ticket {ticket_id} not found.", params={"fields": fields})
    comments, total, complete = _fetch_comments(ticket_id)
    _print_ticket(ticket_id, response.json().get("fields", {}), ac_fields, comments, total, complete)


def _print_ticket(ticket_id: str, fields: dict, ac_fields: list[str], comments: list, total: int, complete: bool) -> None:
    separator = "=" * 70

    print(separator)
    print(f"  TICKET: {ticket_id}   ({DEPLOYMENT}, REST v{API_VERSION})")
    print(separator)
    print(f"  Title    : {fields.get('summary', 'N/A')}")
    print(f"  Type     : {_nested(fields, 'issuetype', 'name')}")
    print(f"  Status   : {_nested(fields, 'status', 'name')}")
    print(f"  Priority : {_nested(fields, 'priority', 'name')}")
    print(f"  Assignee : {_nested(fields, 'assignee', 'displayName') or 'Unassigned'}")
    print(f"  Reporter : {_nested(fields, 'reporter', 'displayName')}")
    print(f"  Updated  : {fields.get('updated') or 'unknown'}")
    print(f"  Observed : {datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')}")

    labels = fields.get("labels", [])
    if labels:
        print(f"  Labels   : {', '.join(labels)}")

    print()
    print("--- DESCRIPTION " + "-" * 54)
    print(_adf_to_text(fields.get("description")).strip() or "(no description)")

    print()
    print("--- ACCEPTANCE CRITERIA " + "-" * 46)
    values = [(f, _adf_to_text(fields.get(f)).strip()) for f in ac_fields]
    values = [(f, v) for f, v in values if v]
    if values:
        for field_id, value in values:
            print(f"[{field_id}]\n{value}" if len(ac_fields) > 1 else value)
    else:
        print("unknown (no populated acceptance-criteria field found; "
              "set JIRA_ACCEPTANCE_CRITERIA_FIELD or check the description)")

    subtasks = fields.get("subtasks", [])
    if subtasks:
        print()
        print("--- SUBTASKS " + "-" * 57)
        for sub in subtasks:
            status = _nested(sub, "fields", "status", "name")
            print(f"  [{status}]  {sub.get('key')} — {_nested(sub, 'fields', 'summary')}")

    links = fields.get("issuelinks", [])
    if links:
        print()
        print("--- LINKED ISSUES " + "-" * 52)
        for link in links:
            link_type = _nested(link, "type", "name")
            if "outwardIssue" in link:
                issue = link["outwardIssue"]
                direction = _nested(link, "type", "outward")
            else:
                issue = link.get("inwardIssue", {})
                direction = _nested(link, "type", "inward")
            key = issue.get("key", "?")
            summary = _nested(issue, "fields", "summary")
            status = _nested(issue, "fields", "status", "name")
            print(f"  {link_type} ({direction}): [{status}] {key} — {summary}")

    print()
    print(f"--- COMMENTS ({len(comments)} of {total}) " + "-" * 40)
    if not complete:
        print(f"  WARNING: incomplete — stopped after {MAX_COMMENT_PAGES} pages; some comments are missing.")
    for i, comment in enumerate(comments, 1):
        author = _nested(comment, "author", "displayName")
        created = comment.get("created", "")[:10]
        print(f"\n  [{i}] id:{comment.get('id', '?')}  {author} \u2014 {created}")
        print(f"  {_adf_to_text(comment.get('body')).strip()}")

    print()
    print(separator)
    print(f"  URL: {_base()}/browse/{ticket_id}")
    print(separator)


def _nested(obj: dict, *keys: str) -> str:
    """Safely traverse nested dict keys."""
    for key in keys:
        if not isinstance(obj, dict):
            return "N/A"
        obj = obj.get(key, {})
    return obj if isinstance(obj, str) else "N/A"


# ---------------------------------------------------------------------------
# Write
# ---------------------------------------------------------------------------

def edit_comment(ticket_id: str, comment_id: str, comment_text: str) -> None:
    """Edit an existing comment on a Jira ticket."""
    _request(
        "put", f"/issue/{ticket_id}/comment/{comment_id}",
        f"Comment {comment_id} not found on {ticket_id}.", json={"body": _text_to_body(comment_text)},
    )
    print(f"Comment {comment_id} updated. Re-fetch the ticket to verify.")
    print(f"View: {_base()}/browse/{ticket_id}")


def post_comment(ticket_id: str, comment_text: str) -> None:
    """Post a comment to a Jira ticket."""
    response = _request(
        "post", f"/issue/{ticket_id}/comment",
        f"Ticket {ticket_id} not found.", json={"body": _text_to_body(comment_text)},
    )
    print(f"Comment posted (id: {response.json().get('id')}). Re-fetch the ticket to verify.")
    print(f"View: {_base()}/browse/{ticket_id}")


def _read_text(args: argparse.Namespace) -> str:
    if args.file:
        path = Path(args.file)
        if not path.exists():
            _fail(f"File not found: {args.file}")
        text = path.read_text(encoding="utf-8")
    else:
        text = args.text
    if not text or not text.strip():
        _fail("Comment text is empty.")
    return text


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Jira CLI Tool — fetch tickets and post comments",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python jira_tool.py fetch PROJ-123
  python jira_tool.py comment PROJ-123 "Testing completed. All scenarios passed."
  python jira_tool.py comment PROJ-123 --file qa-work/PROJ-123/outputs/comment.md
  python jira_tool.py edit PROJ-123 123456 --file qa-work/PROJ-123/outputs/comment.md
        """,
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    fetch_parser = subparsers.add_parser("fetch", help="Fetch and display ticket details")
    fetch_parser.add_argument("ticket_id", metavar="TICKET", help="Jira ticket ID, e.g. PROJ-123")

    edit_parser = subparsers.add_parser("edit", help="Edit an existing comment on a ticket")
    edit_parser.add_argument("ticket_id", metavar="TICKET", help="Jira ticket ID, e.g. PROJ-123")
    edit_parser.add_argument("comment_id", metavar="COMMENT_ID", help="Comment ID (shown in fetch output)")
    edit_group = edit_parser.add_mutually_exclusive_group(required=True)
    edit_group.add_argument("text", nargs="?", metavar="TEXT", help="New comment text (inline)")
    edit_group.add_argument("--file", metavar="FILE", help="Path to a file containing the new comment text")

    comment_parser = subparsers.add_parser("comment", help="Post a comment to a ticket")
    comment_parser.add_argument("ticket_id", metavar="TICKET", help="Jira ticket ID, e.g. PROJ-123")
    comment_group = comment_parser.add_mutually_exclusive_group(required=True)
    comment_group.add_argument("text", nargs="?", metavar="TEXT", help="Comment text (inline)")
    comment_group.add_argument("--file", metavar="FILE", help="Path to a file containing the comment text")

    args = parser.parse_args()

    if args.command == "fetch":
        fetch_ticket(args.ticket_id)
    elif args.command == "edit":
        edit_comment(args.ticket_id, args.comment_id, _read_text(args))
    elif args.command == "comment":
        post_comment(args.ticket_id, _read_text(args))


if __name__ == "__main__":
    main()
