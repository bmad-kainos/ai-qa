# Discovery — Commerce workspace

Scope: complete two-package workspace fixture. Sampled the root npm workspace, both package manifests/configs, one Playwright API test, one Vitest web test, README, CONTRIBUTING, CI, OpenAPI and ADR. No tests were run. AI-QA v1 supports one configured test scope path, so the package choice is a required setup decision.

| Domain | Status | Finding | Evidence | Note |
|---|---|---|---|---|
| Identity and ownership | ✓ Observed | Commerce workspace contains API and storefront packages. | `README.md:3` | Package ownership is separated by path. |
| Repository shape | ✓ Observed | npm workspaces include `packages/api` and `packages/web`. | `package.json:4`, `package.json:5`, `package.json:6` | Multi-scope repository. |
| Architecture and contracts | ✓ Observed | Orders API package owns HTTP contract tests and OpenAPI. | `docs/openapi.yaml:1`, `docs/adr/0001-workspace-boundaries.md:9` | No production implementation included. |
| Stack and build | ✓ Observed | API uses Playwright; web uses Vitest; root scripts compose them. | `packages/api/package.json:5`, `packages/web/package.json:5`, `README.md:7` | Do not blend pack paths. |
| Source and test layout | ✓ Observed | API tests under `packages/api/tests/api`; web tests under `packages/web/tests`. | `packages/api/playwright.config.ts:4`, `packages/api/tests/api/orders.spec.ts:1`, `packages/web/tests/cart.test.ts:1` | Different levels and runners. |
| Test conventions | ✓ Observed | Playwright API spec and Vitest unit test are both represented. | `packages/api/tests/api/orders.spec.ts:1`, `packages/web/tests/cart.test.ts:1` | One test sampled in each scope; insufficient to generalise beyond each package. |
| Environments and dependencies | ◐ Inferred | API test target comes from `ORDERS_API_URL`, default localhost:8080. | `packages/api/playwright.config.ts:5` | Basis: package config only; target not probed. |
| CI and reporting | ✓ Observed | GitHub Actions runs root npm test; API package config writes JUnit XML. | `.github/workflows/tests.yml:16`, `packages/api/playwright.config.ts:5` | CI output not inspected remotely. |
| Git and review | ✓ Observed | Shared `main`, COM ticket branch, Conventional Commit and GitHub `#123` conventions. | `CONTRIBUTING.md:3` | No PR template or history sampled. |
| Work items and docs | ◐ Inferred | GitHub issue references are likely from `#123`; no remote URL/auth evidence. | `CONTRIBUTING.md:3` | Confirm repository provider for operations. |
| Data and external boundaries | ∅ Not found | No database, auth, production API host or deployed environment is defined. | Bounded fixture scan; `README.md:3` | No unsupported assumptions. |
| QA reporting and observability | ∅ Not found | No QA audience or application telemetry convention found. | `.github/workflows/tests.yml:16` | A JUnit report path exists only for API package. |
| Remote access | ? Could not check | Git history, provider identity and recent PRs are unavailable from this fixture snapshot. | Read-only fixture inspection | No authenticated remote probe performed. |
| Configuration scope | ✓ Observed | Root describes two independent test scopes; v1 configures one scope path per run. | `README.md:3`, `docs/adr/0001-workspace-boundaries.md:9` | Product limitation requires the user to choose one package. |

## Needs your input

- Which single scope should Configure first: `packages/api` (Playwright) or `packages/web` (Vitest)? The other scope requires a later separate configuration; v1 has no monorepo overlay.
- Confirm the GitHub repository and non-production `ORDERS_API_URL` before any remote or environment-dependent operation.