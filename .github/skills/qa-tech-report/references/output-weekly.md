# Output Format: Weekly Update

Use for: a project's team weekly update. The message body below is channel-neutral; apply any configured channel formatting from `conventions/reporting.md` `Channel templates`.

---

## Format

```txt
This week:

- [What shipped — one outcome per bullet, plain English]
- [What shipped — omit if nothing else distinct to add]

Next week — we plan to:

- [In-progress work-item summary — brief, outcome-focused]
- [In-progress work-item summary]
- [In-progress work-item summary — max 3]

Any blockers to escalate:
```

---

## Rules

- Maximum 2 bullets under "This week" — derived from git commits
- Maximum 3 bullets under "Next week" — derived from current in-progress work items returned by `workitem.search`
- Omit work-item IDs from the output when they add noise for the intended audience
- Plain English only: avoid infrastructure and code jargon
- Each bullet must be a complete sentence or clear short phrase — not a commit message
- Leave "Any blockers to escalate:" blank if there are none — do not write "None" or "N/A"
- Use the channel's configured format; do not assume platform-specific decoration

---

## Data Sources

"This week" bullets come from the git log output for the user's requested date range.
"Next week" bullets come from configured in-progress work items returned by `workitem.search`, scoped to the confirmed project and sprint when known.

Prioritise tickets/work items using this order:
1. Items where commits were made in the requested date range (cross-reference the git log output).
2. Build/delivery-focused items over review or discovery tasks.
3. Oldest in-progress items (most likely to be near completion).

Keep to 3 bullets maximum. If more items match, select the best 3 and — separately from the weekly-update text — tell the user which were omitted and why so they can override the selection if needed. If the provider is not configured or results are incomplete, say `not available` and do not invent next-week commitments.
