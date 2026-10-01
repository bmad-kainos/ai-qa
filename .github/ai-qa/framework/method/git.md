# Work ID and Git context

Read the project's `.github/ai-qa/project/conventions/git.md` before inferring
branch naming, default/base branch or ticket key syntax. Use the **first
applicable** work-ID source:

1. An explicit work ID or ticket supplied by the user.
2. A ticket key on the confirmed current branch **only if it matches the
   configured project ticket/branch pattern**. If no custom pattern is
   recorded but a project key is already confirmed, match only that key
   followed by a hyphen and decimal ticket number (for example
   `PROJ-1234` with confirmed key `PROJ`), separated from adjacent
   alphanumerics. Do not match arbitrary `<letters>-<digits>` without a
   confirmed key. Name the branch and matched substring as evidence; a
   coincidental number or arbitrary slug is not a ticket ID. If patterns
   are contradictory, mark `⚠` and ask.
3. Otherwise propose `adhoc-YYYYMMDD-slug` using the current UTC date and
   a short sanitized task description; check for an existing work index
   before selecting a collision-free ID. Label it as an ad-hoc work ID,
   never as a provider ticket. Ask if even the task scope is unknown.

Reuse an existing `qa-work/<work-id>/index.md` only if its source revision,
scope and branch still match; follow `artefacts.md` for staleness and
frontmatter. In a standalone read-only request you may use a session work
ID without writing an index.

Local QA file edits require a **non-default branch** and, in an orchestrated
workflow, prior plan approval; L1 adds no separate action prompt. L2 separately
gates branch creation and commits. L4 separately gates pushes/PRs. Never
guess `main`, discard dirty work, edit the default branch, or merge branches.
