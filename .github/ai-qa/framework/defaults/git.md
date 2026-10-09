# Git and PR defaults

These are framework defaults, not observations about a project. Configure may apply a candidate only after discovery and confirmation; mark an applied value `★` with the decision date and source in project conventions. Project evidence and approved conventions take precedence.

## Remote host

No default. Discover from repository remotes and confirmed project context.

## Base branch

No default. Read project conventions; never guess a base branch.

## Protected branches

No default. Discover from repository settings or project documentation, using the read-only Branch protection probe in `method/discovery.md`; do not infer protection from a branch name.

## Branch patterns

Candidate: `feature|bugfix|chore/<ticket>-<slug>`. Ticket syntax and slug constraints remain project-specific and must be confirmed.

## Ticket syntax

No default. Discover issue-key syntax and configured project key; do not interpret arbitrary branch text as a ticket.

## Commit style

Candidate: Conventional Commits.

## Commit types

Use the types supported by the confirmed project convention. Conventional Commit type examples may include `feat`, `fix`, `docs`, `test`, `refactor`, `build`, `ci`, `chore` and `revert`; examples are not a project restriction.

## PR title pattern

Candidate: `<type>: <summary> (<ticket>)`.

## PR types

Use project-confirmed types; do not infer solely from branch names.

## Prefix-to-type mapping

No mapping default. Derive from project conventions and confirm ambiguous cases.

## PR templates

Use the observed project template. Candidate body structure: **Summary** followed by **List of Changes**.

## Exemplar PR

No default. Use a recent, representative project PR if available; recency takes precedence over volume.

## Draft and reviewer policy

No reviewer or draft default. Confirm project policy. Creating a PR is L4 and must be previewed and explicitly approved; a push is a separate L4 action.

## PR body candidate

Candidate structure, adapted from the Feabhas Summary + List of Changes format:

```md
## Summary
<User-facing outcome and ticket intent.>

## List of Changes
- **<area>** <change grounded in the diff>
```

## Options (not defaults)

- Keep the Confluence page empty until testing begins; publish only the scenarios when the user is ready to test.
- Use `.sql` for test-data artefacts where the project requires SQL fixtures.
- Require branch descriptions of 10–45 characters where the project requires that constraint.