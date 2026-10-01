# Discovery — Catalogue Web

Scope: complete fixture snapshot. Sampled both Playwright test paths (2/2 tests), app entry point, package scripts, Playwright config, GitHub Actions, PR template, CONTRIBUTING, Compose, OpenAPI and ADR. No tests were run.

| Domain | Status | Finding | Evidence | Note |
|---|---|---|---|---|
| Identity and ownership | ✓ Observed | TypeScript Catalogue storefront with a browser/API boundary. | `README.md:3`, `docs/adr/0001-catalogue-api.md:13` | Team ownership is documented in CODEOWNERS. |
| Architecture and interfaces | ✓ Observed | Browser calls `GET /api/catalogue`; contract lists products. | `docs/openapi.yaml:8`, `src/main.ts:4` | No server implementation is present in this fixture. |
| Stack and build | ✓ Observed | Vite, TypeScript, Playwright. | `package.json:5`, `package.json:7`, `package.json:12` | — |
| Source and docs layout | ✓ Observed | App under `src/`, API tests under `tests/api/`, browser tests under `tests/e2e/`, docs under `docs/`. | `README.md:3`, `playwright.config.ts:4`, `docs/adr/0001-catalogue-api.md:1` | — |
| Test inventory and conventions | ✓ Observed | Both paths use Playwright `.spec.ts`; API-boundary route mock and empty-result UI case. | `tests/api/catalogue.spec.ts:1`, `tests/api/catalogue.spec.ts:12`, `tests/e2e/catalogue.spec.ts:13` | 2/2 sampled tests are Playwright tests. |
| Fixtures and data | ✓ Observed | Browser tests stub the route; no shared DB is required by tests. | `docs/adr/0001-catalogue-api.md:13`, `tests/api/catalogue.spec.ts:4` | PostgreSQL is available for local service development only. |
| Environments and dependencies | ✓ Observed | Vite defaults to localhost:3000; Compose declares PostgreSQL. | `README.md:7`, `compose.yaml:3` | No deployed API URL or auth config found. |
| CI and reporting | ✓ Observed | GitHub Actions runs npm install and Playwright; JUnit XML is uploaded. | `.github/workflows/tests.yml:16`, `.github/workflows/tests.yml:21` | No test run performed. |
| Git and review | ✓ Observed | `main`, issue references `#123`, Conventional Commits, CODEOWNERS and PR template exist. | `CONTRIBUTING.md:7`, `.github/PULL_REQUEST_TEMPLATE.md:3`, `.github/CODEOWNERS:1` | No recent PR sample available. |
| Requirements and work items | ◐ Inferred | GitHub Issues is indicated by `#123` and PR template; no repository URL or authenticated provider evidence. | `README.md:3`, `.github/PULL_REQUEST_TEMPLATE.md:3` | Basis: local references only. |
| Docs and ADRs | ✓ Observed | OpenAPI and API-boundary ADR are local. | `docs/openapi.yaml:1`, `docs/adr/0001-catalogue-api.md:1` | No remote docs host named. |
| QA reporting and observability | ∅ Not found | No application telemetry or QA report audience convention found beyond JUnit output. | `.github/workflows/tests.yml:21` | Bounded scan of fixture files. |
| Remote access | ? Could not check | GitHub repository identity, current branch history and provider permissions are unavailable from this fixture snapshot. | Read-only fixture inspection | No authenticated probe performed. |

## Needs your input

- Which deployed API environment should be used for any non-mocked integration check? The fixture contains no server implementation or target URL.
