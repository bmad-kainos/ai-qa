#!/usr/bin/env python3
"""
Confluence CLI Tool (no-MCP fallback)
=====================================
Find pages, update content and append test scenarios/evidence on Confluence
Cloud or Server/Data Center.

Usage:
    python confluence_tool.py find --space DOCS "Exact page title"
    python confluence_tool.py get 123456789
    python confluence_tool.py update 123456789 --file path/to/content.md
    python confluence_tool.py append 123456789 --file path/to/content.md

Configuration:
    Copy .env.example to .env next to this script and fill in your values.
    Never commit .env to version control.
"""

from __future__ import annotations

import argparse
import base64
import html
import os
import re
import sys
from pathlib import Path
from urllib.parse import urlparse

import requests
from dotenv import load_dotenv

try:
    import truststore
    truststore.inject_into_ssl()
except ImportError:
    pass

load_dotenv(Path(__file__).parent / ".env")

CONFLUENCE_BASE_URL = os.environ.get("CONFLUENCE_BASE_URL", "").rstrip("/")
DEPLOYMENT = os.environ.get("ATLASSIAN_DEPLOYMENT", "server").strip().lower()
CONFLUENCE_PAT = os.environ.get("CONFLUENCE_PAT", "")
ATLASSIAN_EMAIL = os.environ.get("ATLASSIAN_EMAIL", "")
ATLASSIAN_API_TOKEN = os.environ.get("ATLASSIAN_API_TOKEN", "")
TRUSTED_HOSTS = {h.strip().lower() for h in os.environ.get("ATLASSIAN_TRUSTED_HOSTS", "").split(",") if h.strip()}

SAFE_LINK_SCHEMES = {"http", "https", "mailto"}


def _fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def _base() -> str:
    """Return the base URL, refusing anything that could leak credentials."""
    if DEPLOYMENT not in ("cloud", "server"):
        _fail("ATLASSIAN_DEPLOYMENT must be 'cloud' or 'server'.")
    if not CONFLUENCE_BASE_URL:
        _fail("CONFLUENCE_BASE_URL is not set. Check your .env file.")
    parsed = urlparse(CONFLUENCE_BASE_URL)
    host = (parsed.hostname or "").lower()
    if parsed.scheme != "https" or not host or parsed.username or parsed.password:
        _fail("CONFLUENCE_BASE_URL must be an https:// URL without embedded credentials.")
    allowed = host in TRUSTED_HOSTS or (DEPLOYMENT == "cloud" and host.endswith(".atlassian.net"))
    if (DEPLOYMENT == "cloud" or TRUSTED_HOSTS) and not allowed:
        _fail(f"Host '{host}' is not trusted. Use *.atlassian.net or list it in ATLASSIAN_TRUSTED_HOSTS.")
    return CONFLUENCE_BASE_URL


def _get_headers() -> dict:
    _base()
    if DEPLOYMENT == "cloud":
        if not (ATLASSIAN_EMAIL and ATLASSIAN_API_TOKEN):
            _fail("ATLASSIAN_EMAIL and ATLASSIAN_API_TOKEN must be set for Cloud. Check your .env file.")
        raw = f"{ATLASSIAN_EMAIL}:{ATLASSIAN_API_TOKEN}".encode("utf-8")
        authorization = "Basic " + base64.b64encode(raw).decode("ascii")
    else:
        if not CONFLUENCE_PAT:
            _fail("CONFLUENCE_PAT is not set. Check your .env file.")
        authorization = f"Bearer {CONFLUENCE_PAT}"
    return {
        "Authorization": authorization,
        "Content-Type": "application/json",
        "Accept": "application/json",
    }


def _handle_response(response, action: str) -> None:
    if response.status_code in (401, 403):
        _fail(f"HTTP {response.status_code}. Check your credentials and permissions in .env.")
    if response.status_code == 404:
        _fail("Page not found.")
    if not response.ok:
        print(f"ERROR: {action} failed — HTTP {response.status_code}", file=sys.stderr)
        sys.exit(1)


# ---------------------------------------------------------------------------
# Markdown → Confluence Storage Format converter
# ---------------------------------------------------------------------------

def _md_to_confluence(md_text: str) -> str:
    """
    Convert Markdown to Confluence storage format (XHTML-based).
    Handles: headings, bold/italic, code blocks (with language), inline code,
    tables, ordered/unordered lists, horizontal rules, paragraphs.
    Preview the result before publishing; nested lists and macros are not supported.
    """
    lines = md_text.splitlines()
    output: list[str] = []
    i = 0

    while i < len(lines):
        line = lines[i]

        fence_match = re.match(r"^```(\w*)", line)
        if fence_match:
            lang = fence_match.group(1) or "none"
            code_lines = []
            i += 1
            while i < len(lines) and not lines[i].startswith("```"):
                code_lines.append(lines[i])
                i += 1
            code_body = "\n".join(code_lines).replace("]]>", "]]]]><![CDATA[>")
            output.append(
                f'<ac:structured-macro ac:name="code">'
                f'<ac:parameter ac:name="language">{lang}</ac:parameter>'
                f'<ac:parameter ac:name="linenumbers">false</ac:parameter>'
                f'<ac:plain-text-body><![CDATA[{code_body}]]></ac:plain-text-body>'
                f'</ac:structured-macro>'
            )
            i += 1
            continue

        heading_match = re.match(r"^(#{1,6})\s+(.*)", line)
        if heading_match:
            level = len(heading_match.group(1))
            text = _inline(heading_match.group(2))
            if level == 3:  # scenario headings are blue per the scenario format
                output.append(f'<h{level}><span style="color: rgb(0,82,204);">{text}</span></h{level}>')
            else:
                output.append(f"<h{level}>{text}</h{level}>")
            i += 1
            continue

        if re.match(r"^---+$", line.strip()):
            output.append("<hr/>")
            i += 1
            continue

        if "|" in line and line.strip().startswith("|"):
            table_lines = []
            while i < len(lines) and "|" in lines[i] and lines[i].strip().startswith("|"):
                table_lines.append(lines[i])
                i += 1
            output.append(_table(table_lines))
            continue

        if re.match(r"^[-*]\s+", line):
            items = []
            while i < len(lines) and re.match(r"^[-*]\s+", lines[i]):
                items.append(_inline(re.sub(r"^[-*]\s+", "", lines[i])))
                i += 1
            output.append("<ul>" + "".join(f"<li>{item}</li>" for item in items) + "</ul>")
            continue

        if re.match(r"^\d+\.\s+", line):
            items = []
            while i < len(lines) and re.match(r"^\d+\.\s+", lines[i]):
                items.append(_inline(re.sub(r"^\d+\.\s+", "", lines[i])))
                i += 1
            output.append("<ol>" + "".join(f"<li>{item}</li>" for item in items) + "</ol>")
            continue

        if not line.strip():
            output.append("")
            i += 1
            continue

        output.append(f"<p>{_inline(line)}</p>")
        i += 1

    return "\n".join(output)


def _escape_xhtml(text: str) -> str:
    return text.replace("&", "&amp;").replace("<", "&lt;").replace(">", "&gt;")


def _inline(text: str) -> str:
    """Convert inline markdown to storage format; all source text is XML-escaped."""
    # Generated markup is stashed behind NUL placeholders so later regexes cannot touch it.
    stash: list[str] = []

    def keep(markup: str) -> str:
        stash.append(markup)
        return f"\x00{len(stash) - 1}\x00"

    text = text.replace("\x00", "")
    text = re.sub(r"`([^`]+)`", lambda m: keep(f"<code>{_escape_xhtml(m.group(1))}</code>"), text)
    text = _escape_xhtml(text)

    def link(m: re.Match) -> str:
        label, url = m.group(1), html.unescape(m.group(2)).strip()
        if urlparse(url).scheme.lower() not in SAFE_LINK_SCHEMES:
            return label  # drop unsafe schemes such as javascript:
        opening = keep(f'<a href="{html.escape(url, quote=True)}">')
        return f"{opening}{label}{keep('</a>')}"

    text = re.sub(r"\[([^\]]+)\]\(([^)\s]+)\)", link, text)
    text = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
    text = re.sub(r"__(.+?)__", r"<strong>\1</strong>", text)
    text = re.sub(r"\*(.+?)\*", r"<em>\1</em>", text)
    text = re.sub(r"(?<!\w)_(.+?)_(?!\w)", r"<em>\1</em>", text)
    text = re.sub(r"~~(.+?)~~", r"<del>\1</del>", text)
    return re.sub(r"\x00(\d+)\x00", lambda m: stash[int(m.group(1))], text)


def _table(table_lines: list[str]) -> str:
    html_rows = ["<table><tbody>"]
    for idx, row in enumerate(table_lines):
        cells = [c.strip() for c in row.strip().strip("|").split("|")]
        if all(re.match(r"^[-: ]+$", c) for c in cells):
            continue
        tag = "th" if idx == 0 else "td"
        html_rows.append("<tr>" + "".join(f"<{tag}>{_inline(c)}</{tag}>" for c in cells) + "</tr>")
    html_rows.append("</tbody></table>")
    return "\n".join(html_rows)


# ---------------------------------------------------------------------------
# API commands
# ---------------------------------------------------------------------------

def find_pages(space_key: str, query: str) -> None:
    """Search for pages in a Confluence space by exact title."""
    url = f"{_base()}/rest/api/content"
    params = {"spaceKey": space_key, "title": query, "expand": "version,space", "limit": 20}
    response = requests.get(url, headers=_get_headers(), params=params, timeout=30)
    _handle_response(response, "Search")

    data = response.json()
    results = data.get("results", [])
    if not results:
        print(f"No pages found in space '{space_key}' matching '{query}'")
        return

    print(f"\nFound {len(results)} page(s) in space '{space_key}':\n")
    for page in results:
        page_id = page["id"]
        version = page.get("version", {}).get("number", "?")
        print(f"  ID: {page_id}  v{version}  {page['title']}")
        print(f"  URL: {_base()}/spaces/{space_key}/pages/{page_id}")
        print()
    if data.get("_links", {}).get("next"):
        print("WARNING: more results exist than shown; narrow the title.")


def get_page(page_id: str) -> None:
    """Display page info and the complete storage-format body."""
    data = _fetch_page(page_id, with_body=True)
    space = data.get("space", {}).get("key", "?")

    sep = "=" * 70
    print(sep)
    print(f"  PAGE ID : {page_id}")
    print(f"  Title   : {data.get('title', '?')}")
    print(f"  Space   : {space}")
    print(f"  Version : {data.get('version', {}).get('number', '?')}")
    print(sep)
    print("\nContent (storage format):\n")
    print(data.get("body", {}).get("storage", {}).get("value", ""))
    print(f"\n  URL: {_base()}/spaces/{space}/pages/{page_id}")
    print(sep)


def _fetch_page(page_id: str, with_body: bool) -> dict:
    expand = "body.storage,version,space,ancestors" if with_body else "version,space"
    url = f"{_base()}/rest/api/content/{page_id}"
    response = requests.get(url, headers=_get_headers(), params={"expand": expand}, timeout=30)
    _handle_response(response, "Fetch page")
    return response.json()


def _put_body(page_id: str, data: dict, body: str, action: str) -> int:
    new_version = data["version"]["number"] + 1
    payload = {
        "version": {"number": new_version},
        "title": data["title"],
        "type": "page",
        "body": {"storage": {"value": body, "representation": "storage"}},
    }
    url = f"{_base()}/rest/api/content/{page_id}"
    response = requests.put(url, headers=_get_headers(), json=payload, timeout=30)
    _handle_response(response, action)
    return new_version


def update_page(page_id: str, md_content: str) -> None:
    """Replace the full page body with converted markdown content."""
    data = _fetch_page(page_id, with_body=False)
    version = _put_body(page_id, data, _md_to_confluence(md_content), "Update page")
    print(f"Page updated (v{version}). Run 'get' to verify the result.")
    print(f"URL: {_base()}/spaces/{data['space']['key']}/pages/{page_id}")


def append_to_page(page_id: str, md_content: str) -> None:
    """Append markdown content to the bottom of an existing page."""
    data = _fetch_page(page_id, with_body=True)
    body = data["body"]["storage"]["value"] + "\n" + _md_to_confluence(md_content)
    version = _put_body(page_id, data, body, "Append to page")
    print(f"Content appended (v{version}). Run 'get' to verify the result.")
    print(f"URL: {_base()}/spaces/{data['space']['key']}/pages/{page_id}")


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(
        description="Confluence CLI Tool — find pages, update and append content",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  python confluence_tool.py find --space DOCS "Exact page title"
  python confluence_tool.py get 123456789
  python confluence_tool.py update 123456789 --file qa-work/PROJ-123/outputs/08_test_plan.md
  python confluence_tool.py append 123456789 --file qa-work/PROJ-123/outputs/comment.md
        """,
    )
    subparsers = parser.add_subparsers(dest="command", required=True)

    find_p = subparsers.add_parser("find", help="Search for pages in a space by exact title")
    find_p.add_argument("--space", required=True, metavar="SPACE_KEY", help="Confluence space key, e.g. DOCS")
    find_p.add_argument("query", metavar="TITLE", help="Exact page title to search for")

    get_p = subparsers.add_parser("get", help="Display page info and the full storage body")
    get_p.add_argument("page_id", metavar="PAGE_ID", help="Confluence page ID")

    update_p = subparsers.add_parser("update", help="Replace page content with markdown file")
    update_p.add_argument("page_id", metavar="PAGE_ID", help="Confluence page ID")
    update_p.add_argument("--file", required=True, metavar="FILE", help="Path to markdown file")

    append_p = subparsers.add_parser("append", help="Append markdown content to an existing page")
    append_p.add_argument("page_id", metavar="PAGE_ID", help="Confluence page ID")
    append_p.add_argument("--file", required=True, metavar="FILE", help="Path to markdown file")

    args = parser.parse_args()

    if args.command == "find":
        find_pages(args.space, args.query)
    elif args.command == "get":
        get_page(args.page_id)
    else:
        md_path = Path(args.file)
        if not md_path.exists():
            _fail(f"File not found: {args.file}")
        md_content = md_path.read_text(encoding="utf-8")
        if args.command == "update":
            update_page(args.page_id, md_content)
        else:
            append_to_page(args.page_id, md_content)


if __name__ == "__main__":
    main()
