# Discovery — Empty starter

Scope: complete fixture snapshot. The only project file is the README (1/1 files read); no tests, CI, source, manifests, docs index, infrastructure or provider configuration exist. No tests or external probes were run. `★` values below are expected only after Configure proposes them and the user approves them; they are conventions, not discovered project facts.

| Domain | Status | Finding | Evidence | Note |
|---|---|---|---|---|
| Repository shape and identity | ✓ Observed | README-only empty starter. | `README.md:1` | No product or owner identified. |
| Architecture and technology | ∅ Not found | No source, service boundary, language, build manifest or interface found in bounded file inventory. | `README.md:3`; bounded inventory | Do not infer a stack. |
| Tests and execution | ∅ Not found | No test paths, framework, commands or reports found. | `README.md:3`; bounded inventory | No suite to run. |
| Data, environments and deployment | ∅ Not found | No data store, environment, infrastructure or deploy stage found. | `README.md:3`; bounded inventory | — |
| CI and QA reporting | ∅ Not found | No CI, QA evidence or report audience found. | `README.md:3`; bounded inventory | — |
| Git and review | ? Could not check | No repository history/remote is available in this fixture snapshot. | Read-only fixture inspection | Check real default branch and remote before branch/PR work. |
| Requirements, providers and docs | ∅ Not found | No ticket, tracker, docs root, provider URL, ADR or remote-docs location appears in README. | `README.md:3`; bounded inventory | No integration is configured. |
| Configure defaults | ★ Default established | If accepted, use dated framework defaults for Git, QA process and reporting; do not select a test pack or invent a test command. | Configure proposal dated 2026-10-01 | These are approved defaults, not observations. |

## Needs your input

- What is the project intended to build? This determines whether a language/test stack and test scope can be selected.
- Confirm the proposed defaults and actual base branch after this fixture is installed as a repository.
