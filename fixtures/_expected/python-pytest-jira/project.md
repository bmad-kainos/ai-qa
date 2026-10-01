# Project Context — Stock API

## Summary
High confidence: Python service owns stock quantity reads and updates. Sources: `README.md:3`, `docs/adr/0001-stock-source.md:13`.

## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| Stock API | service | `src/stock/` | Python / FastAPI | Read available quantity by SKU |
| Stock unit tests | test suite | `tests/unit/` | pytest | Validate quantity rules |
| Stock API tests | test suite | `tests/integration/` | pytest / httpx | Exercise ASGI boundary |
| Checkout | external service | ADR boundary | HTTP (details not specified) | Request reservations |
Sources: `src/stock/api.py:7`, `tests/unit/test_stock_rules.py:4`, `tests/integration/test_stock_api.py:5`, `docs/adr/0001-stock-source.md:13`.

## Technology stack
High confidence: Python 3.11+, FastAPI, pytest, httpx. Sources: `README.md:7`, `pyproject.toml:11`.

## Environments
Medium confidence: local Compose PostgreSQL and Kubernetes deployment; no API test URL is configured. Sources: `compose.yaml:7`, `deploy/stock-deployment.yaml:2`, `README.md:9`.

## Data stores and external dependencies
High confidence: PostgreSQL is the local/deployed data store; checkout is an external reservation boundary. Sources: `compose.yaml:7`, `docs/adr/0001-stock-source.md:13`.

## CI/CD
High confidence: GitHub Actions installs editable test extras, runs pytest and uploads JUnit XML. Sources: `.github/workflows/tests.yml:14`, `.github/workflows/tests.yml:16`, `.github/workflows/tests.yml:20`.

## Test landscape
High confidence: unit and ASGI integration tests, common conftest client fixture, JUnit output. Sources: `pyproject.toml:14`, `tests/conftest.py:7`, `tests/integration/test_stock_api.py:5`, `README.md:7`.

## Constraints
High confidence: isolate test data and never target production; cross-service testing requires an identified sandbox. Sources: `README.md:9`, `docs/adr/0001-stock-source.md:17`.

## Documentation sources
High confidence: README, ADR, and runbook links are documented. Sources: `README.md:13`, `docs/adr/0001-stock-source.md:1`.

## Unknowns and conflicts
Medium confidence: Jira/Confluence Cloud is inferred from Atlassian hostnames; authentication and checkout sandbox remain unverified. Sources: `README.md:13`, `CONTRIBUTING.md:8`, `discovery.md`.

## Provenance
High confidence: local fixture files; no test execution, Atlassian probe, or remote-document retrieval. Sources: `.github/workflows/tests.yml:16`, `README.md:13`.
