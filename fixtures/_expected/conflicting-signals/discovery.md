# Discovery — Pricing Service (conflicting signals)

Scope: complete fixture snapshot. Sampled package scripts/configuration, one unit test, one integration test, README, CONTRIBUTING, ADR, PR template and workflow. No tests or remote operations were run.

| Domain | Status | Finding | Evidence | Note |
|---|---|---|---|---|
| Identity and ownership | ✓ Observed | Node/TypeScript pricing service; owner is not identified. | `README.md:3` | — |
| Test command and framework | ⚠ Conflict | CONTRIBUTING says Jest via `npm test`; package script runs Vitest. Integration script separately invokes Playwright. | `CONTRIBUTING.md:9`, `package.json:6`, `package.json:8` | Do not choose one command silently. |
| Test paths and conventions | ✗ No consistent convention | Unit tests use Vitest `tests/unit/*.test.ts`; integration uses Playwright `tests/integration/*.spec.ts`. | `vitest.config.ts:5`, `tests/unit/pricing.test.ts:1`, `playwright.config.ts:4`, `tests/integration/orders.spec.ts:1` | Both patterns are observed and intentionally differ. |
| Work-item provider | ⚠ Conflict | CONTRIBUTING retains self-hosted Jira and `JIRA-123`; README and ADR say new work is Azure Boards `AB#123`, while README/PR template also reference GitHub Issues `#123`. | `CONTRIBUTING.md:5`, `README.md:3`, `docs/adr/0001-legacy-tracker.md:13`, `.github/PULL_REQUEST_TEMPLATE.md:3` | Jira may remain relevant for historical items. |
| Deployment inference | ◐ Inferred | Jira hostname is self-hosted and suggests Server/DC; no serverInfo probe was performed. | `CONTRIBUTING.md:5` | Basis: one URL only; do not treat as confirmed deployment. |
| CI and review | ✓ Observed | GitHub Actions runs `npm test`; PR template references GitHub issue closure. | `.github/workflows/tests.yml:1`, `.github/PULL_REQUEST_TEMPLATE.md:3` | CI does not cover integration script. |
| Git conventions | ✓ Observed | CONTRIBUTING uses `feature/JIRA-123` and bugfix branch forms. | `CONTRIBUTING.md:5` | Ticket syntax conflicts with newer README/ADR signals. |
| QA reporting | ∅ Not found | No report audience or product telemetry convention found in bounded local scan. | `.github/workflows/tests.yml:1` | JUnit paths exist in runner config only. |
| Remote access | ? Could not check | Jira, Azure Boards and GitHub provider identity/permissions and recent PRs were not probed. | Read-only fixture inspection | Need provider confirmation before remote operations. |

## Needs your input

- Which test runner is authoritative for each path, and should `npm test` remain a unit-only command?
- Is Jira still required for open historical work, and which provider owns new work: Azure Boards or GitHub Issues?
