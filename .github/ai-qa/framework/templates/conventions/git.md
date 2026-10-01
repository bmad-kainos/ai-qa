# Git and PR conventions

> Generic source template. Only Configure, following an approved L5 adaptation,
> renders this to `.github/ai-qa/project/conventions/git.md`.

<!-- ai-qa:managed:start -->
| Field | Project value | Confidence / source link and revision |
|---|---|---|
| Default branch and protected branch policy | ∅ unknown | ∅ |
| Working branch naming and ticket-reference policy | ∅ unknown | ∅ |
| Approved branch base and sync policy | ∅ unknown | ∅ |
| Existing branch/dirty-worktree handling | ∅ unknown | ∅ |
| Commit scope, message and author policy | ∅ unknown | ∅ |
| Remote(s), draft PR title/body and review conventions | ∅ unknown | ∅ |
| Push, merge and release permissions | No automatic push or merge | Framework safety rule |

L1 allows local test/plan changes **only off the default branch**; workflow plans
must be approved before orchestrated edits, but L1 adds no separate action prompt.
L2 separately gates local branch creation and commits; L4 separately gates pushes
and PR creation. Never infer `main`, force a checkout or merge on behalf of QA.
<!-- ai-qa:managed:end -->

<!-- ai-qa:user -->
Project-authored Git/PR rules; preserve verbatim on refresh.
<!-- /ai-qa:user -->
