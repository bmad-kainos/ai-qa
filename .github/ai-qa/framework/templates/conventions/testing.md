# Testing conventions

> Generic template; Configure renders to `.github/ai-qa/project/conventions/testing.md`
> only after L5 approval. Select *observed* framework packs, never assume a stack.

<!-- ai-qa:managed:start -->
| Field | Project value | Evidence/status |
|---|---|---|
| Test framework(s), versions and matching packs | ∅ unknown | ∅ |
| Unit/integration/E2E/manual test roots and selectors | ∅ unknown | ∅ |
| File/test naming, tags and ticket marker | ∅ unknown | ∅ |
| Fixture and test-data location, ownership and cleanup | ∅ unknown | ∅ |
| Install, targeted validate, full validate and lint commands | ∅ unknown | ∅ |
| Safe local runs versus gated environment/full runs | ∅ unknown | ∅ |
| Test globs for rendered instructions | ∅ unknown | ∅ |
| Reports, coverage and baseline provenance | ∅ unknown | ∅ |

Unit tests are developer-owned; QA checks their existence and acceptance-criteria coverage.
Do not infer passing tests from source or invent a coverage percentage. Require a documented
safe command/environment for an ungated local run; L3 applies to shared/environment-dependent
or full runs. If multiple stacks coexist, list each with distinct paths and packs.
<!-- ai-qa:managed:end -->

<!-- ai-qa:user -->
Project-authored testing conventions; preserve verbatim on refresh.
<!-- /ai-qa:user -->
