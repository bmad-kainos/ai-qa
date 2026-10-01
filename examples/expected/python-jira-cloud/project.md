# Project Context — Stock API

<!-- ai-qa:managed -->
## Summary
High: Python stock service ([README](../../fixtures/python-jira-cloud/README.md)).
## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| Stock API | service | `pyproject.toml` | Python/FastAPI | Quantity updates |
| Checkout boundary | external service | `docs/adr/` | HTTP (unspecified) | Reservations |
## Technology stack
High: Python, FastAPI, pytest and httpx ([manifest](../../fixtures/python-jira-cloud/pyproject.toml)).
## Environments
Medium: local Postgres; deployed base URL comes from `TEST_BASE_URL` ([README](../../fixtures/python-jira-cloud/README.md)).
## Data stores and external dependencies
High: PostgreSQL and checkout service ([Compose](../../fixtures/python-jira-cloud/compose.yaml), [ADR](../../fixtures/python-jira-cloud/docs/adr/0001-stock-source.md)).
## CI/CD
Low: no CI config in fixture ([discovery](discovery.md)).
## Test landscape
Medium: one pytest test and JUnit configuration ([test](../../fixtures/python-jira-cloud/tests/test_stock.py), [manifest](../../fixtures/python-jira-cloud/pyproject.toml)).
## Constraints
Medium: checkout integration requires sandbox ([ADR](../../fixtures/python-jira-cloud/docs/adr/0001-stock-source.md)).
## Documentation sources
High: [README](../../fixtures/python-jira-cloud/README.md), [ADR](../../fixtures/python-jira-cloud/docs/adr/0001-stock-source.md).
## Unknowns and conflicts
Medium: Jira Cloud inferred only; checkout sandbox unknown ([discovery](discovery.md)).
## Provenance
High: local files only; provider not authenticated/probed.
<!-- ai-qa:user -->
Preserved project notes.
