# Git conventions — expected Configure defaults

| Field | Value | Status and provenance |
|---|---|---|
| Base branch | `main` (confirm against the real remote) | ★ Default established 2026-10-01 after user approval; not observed in fixture |
| Branch patterns | `feature|bugfix|chore/<ticket>-<slug>` | ★ Default established 2026-10-01 after user approval |
| Ticket syntax | Project-defined ticket key; unknown until configured | ∅ Not found |
| Commit style | Conventional Commits | ★ Default established 2026-10-01 after user approval |
| PR title pattern | `<type>: <summary> (<ticket>)` | ★ Default established 2026-10-01 after user approval |
| PR body | Summary and List of Changes | ★ Default established 2026-10-01 after user approval |
| PR types and templates | Confirm during setup; none observed | ∅ Not found |

Do not create a branch or PR from these defaults without checking the real project's remote, protected branches, ticket syntax, template and reviewer policy.
