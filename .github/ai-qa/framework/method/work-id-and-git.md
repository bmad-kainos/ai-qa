# Work ID and Git context

Resolve work ID in this order:

1. **Explicit argument or ticket** supplied by the user.
2. **Ticket from the current branch**, only when it matches the configured `Ticket syntax` / `Branch patterns` in `.github/ai-qa/project/conventions/git.md`. If patterns are absent, do not guess the ticket; use the ad-hoc form.
3. **Ad-hoc work ID:** `adhoc-<yyyymmdd>-<slug>` using the current date and a concise, sanitised task description. Check for an existing index before selecting a collision-free ID.

Name the branch and matched ticket substring as evidence. A coincidental number or arbitrary `<letters>-<digits>` sequence is not a ticket. If branch patterns conflict, record `⚠` and ask. An ad-hoc ID is not a provider ticket.

Read the project's `conventions/git.md` before inferring a branch name, default/base branch or ticket syntax. Never guess the base branch; read it from project conventions. Do not edit on the default branch. Confirm the current branch before local changes, and do not discard dirty work. A branch never implies a push; push and PR are separate L4 actions. Never merge.

Reuse `qa-work/<work-id>/index.md` only if scope, branch and inputs still match; follow `artefacts.md` for front-matter and staleness. If an existing work ID collides with another scope, ask rather than overwrite it.
