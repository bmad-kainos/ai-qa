#!/usr/bin/env python3
"""
Jira CLI Tool (no-MCP fallback)
===============================
Fetch ticket details and post or edit comments on Jira Cloud or Server/Data Center.

Usage:
    python jira_tool.py fetch PROJ-123
    python jira_tool.py comment PROJ-123 "Your comment text here"
    python jira_tool.py comment PROJ-123 --file path/to/comment.md
    python jira_tool.py edit PROJ-123 <comment-id> --file path/to/comment.md

Configuration:
    Copy .env.example to .env next to this script and fill in your values.
    Never commit .env to version control.
"""

import argparse
import base64
import os
import sys
from pathlib import Path

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

FIELDS = "summary,description,status,issuetype,priority,assignee,reporter,labels,comment,subtasks,issuelinks,fixVersions"


def _fail(message: str) -> None:
    print(f"ERROR: {message}", file=sys.stderr)
    sys.exit(1)


def _get_headers() -> dict:
    if not JIRA_BASE_URL:
        _fail("JIRA_BASE_URL is not set. Check your .env file.")
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


def _check(response: requests.Response, not_found: str) -> None:
    if response.status_code == 404:
        _fail(not_found)
    if response.status_code in (401, 403):
        _fail(f"HTTP {response.status_code}. Check your credentials and permissions in .env.")
    response.raise_for_status()


def fetch_ticket(ticket_id: str) -> None:
    """Fetch and display full ticket details including all comments."""
    url = f"{JIRA_BASE_URL}/rest/api/2/issue/{ticket_id}"
    response = requests.get(
        url, headers=_get_headers(), params={"fields": FIELDS},
        verify=_get_ssl_verify(), timeout=30,
    )
    _check(response, f"Ticket {ticket_id} not found.")
    _print_ticket(ticket_id, response.json().get("fields", {}))


def _print_ticket(ticket_id: str, fields: dict) -> None:
    separator = "=" * 70

    print(separator)
    print(f"  TICKET: {ticket_id}")
    print(separator)
    print(f"  Title    : {fields.get('summary', 'N/A')}")
    print(f"  Type     : {_nested(fields, 'issuetype', 'name')}")
    print(f"  Status   : {_nested(fields, 'status', 'name')}")
    print(f"  Priority : {_nested(fields, 'priority', 'name')}")
    print(f"  Assignee : {_nested(fields, 'assignee', 'displayName') or 'Unassigned'}")
    print(f"  Reporter : {_nested(fields, 'reporter', 'displayName')}")

    labels = fields.get("labels", [])
    if labels:
        print(f"  Labels   : {', '.join(labels)}")

    print()
    print("--- DESCRIPTION " + "-" * 54)
    print(fields.get("description") or "(no description)")

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

    comments = fields.get("comment", {}).get("comments", [])
    if comments:
        print()
        print("--- COMMENTS " + "-" * 57)
        for i, comment in enumerate(comments, 1):
            author = _nested(comment, "author", "displayName")
            created = comment.get("created", "")[:10]
            print(f"\n  [{i}] id:{comment.get('id', '?')}  {author} \u2014 {created}")
            print(f"  {comment.get('body', '')}")
    else:
        print()
        print("--- COMMENTS (none) " + "-" * 50)

    print()
    print(separator)
    print(f"  URL: {JIRA_BASE_URL}/browse/{ticket_id}")
    print(separator)


def _nested(obj: dict, *keys: str) -> str:
    """Safely traverse nested dict keys."""
    for key in keys:
        if not isinstance(obj, dict):
            return "N/A"
        obj = obj.get(key, {})
    return obj if isinstance(obj, str) else "N/A"


def edit_comment(ticket_id: str, comment_id: str, comment_text: str) -> None:
    """Edit an existing comment on a Jira ticket."""
    url = f"{JIRA_BASE_URL}/rest/api/2/issue/{ticket_id}/comment/{comment_id}"
    response = requests.put(
        url, headers=_get_headers(), json={"body": comment_text},
        verify=_get_ssl_verify(), timeout=30,
    )
    _check(response, f"Comment {comment_id} not found on {ticket_id}.")
    print(f"Comment {comment_id} updated successfully.")
    print(f"View: {JIRA_BASE_URL}/browse/{ticket_id}")


def post_comment(ticket_id: str, comment_text: str) -> None:
    """Post a comment to a Jira ticket."""
    url = f"{JIRA_BASE_URL}/rest/api/2/issue/{ticket_id}/comment"
    response = requests.post(
        url, headers=_get_headers(), json={"body": comment_text},
        verify=_get_ssl_verify(), timeout=30,
    )
    _check(response, f"Ticket {ticket_id} not found.")
    print(f"Comment posted successfully (id: {response.json().get('id')})")
    print(f"View: {JIRA_BASE_URL}/browse/{ticket_id}")


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
