# Discovery — Stock API

Scope: complete fixture snapshot. Sampled 4 tests across unit and integration paths (4/4 use `test_*.py`); also reviewed pyproject, conftest, README, CONTRIBUTING, CI, Compose, Kubernetes, source and ADR. No tests or remote operations were run.

| Domain | Status | Finding | Evidence | Note |
|---|---|---|---|---|
| Identity and ownership | ✓ Observed | Stock API owns quantity reads and updates. | `README.md:3`, `docs/adr/0001-stock-source.md:13` | Checkout owns reservations. |
| Architecture and interfaces | ✓ Observed | FastAPI exposes `GET /stock/{sku}` and returns quantity by SKU. | `src/stock/api.py:7`, `tests/integration/test_stock_api.py:5` | No auth scheme is configured. |
| Stack and build | ✓ Observed | Python 3.11+, FastAPI, pytest and httpx. | `README.md:7`, `pyproject.toml:11` | Editable install uses project test extra. |
| Source and docs layout | ✓ Observed | Source is in `src/stock`; tests split into unit and integration; docs/ADR are local. | `pyproject.toml:14`, `docs/adr/0001-stock-source.md:1` | — |
| Test inventory and conventions | ✓ Observed | Unit rules and ASGI integration tests use pytest functions and a shared client fixture. | `tests/unit/test_stock_rules.py:4`, `tests/integration/test_stock_api.py:5`, `tests/conftest.py:7` | 4/4 sampled tests use `test_` naming. |
| Fixtures and data | ✓ Observed | Function-scoped TestClient fixture resets an in-memory SKU map; Compose uses PostgreSQL. | `tests/conftest.py:6`, `compose.yaml:7` | Tests shown do not depend on a running database. |
| Environments and deployment | ✓ Observed | Kubernetes deployment targets namespace `commerce`; DB URL is injected by a Kubernetes Secret. | `deploy/stock-deployment.yaml:2`, `deploy/stock-deployment.yaml:24` | No deployed API URL supplied. |
| CI and reporting | ✓ Observed | GitHub Actions installs test extra, runs pytest, uploads JUnit XML. | `.github/workflows/tests.yml:14`, `.github/workflows/tests.yml:16`, `.github/workflows/tests.yml:20` | No suite run during discovery. |
| Git and review | ✓ Observed | Main-based ticket branches, Conventional Commits, and one-owner approval are documented. | `CONTRIBUTING.md:5`, `CONTRIBUTING.md:6`, `CONTRIBUTING.md:12` | No PR template or remote PR history sampled. |
| Work items and docs | ◐ Inferred | `*.atlassian.net` URLs identify Jira/Confluence Cloud as likely deployments. | `README.md:13`, `CONTRIBUTING.md:7`, `CONTRIBUTING.md:8` | Host evidence does not prove authentication or deployment type; `serverInfo` not probed. |
| QA reporting and observability | ∅ Not found | No telemetry or QA audience/channel convention found in bounded local scan. | `.github/workflows/tests.yml:20` | JUnit is observed, product telemetry is not. |
| Remote access | ? Could not check | Jira and Confluence permissions, serverInfo, and remote pages were not accessible from fixture evidence alone. | Read-only fixture inspection | Configure must confirm provider/transport before remote-docs pass. |

## Needs your input

- Confirm Jira Cloud deployment and available read-only transport if a safe `serverInfo` probe is unavailable.
- Identify the non-production checkout sandbox before any cross-service test is designed.
