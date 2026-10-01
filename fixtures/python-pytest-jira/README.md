# Stock API

Stock API owns stock quantity reads and updates for the commerce platform. The HTTP service is implemented under `src/stock/`; the ownership boundary and checkout dependency are described in [ADR 0001](docs/adr/0001-stock-source.md).

## Development and tests

Python 3.11+ is required. Install the project and test extras with `python -m pip install -e '.[test]'`; run `python -m pytest tests/` for the full suite, or select `tests/unit/` and `tests/integration/` independently. Pytest writes JUnit XML to `test-results/junit.xml`. Unit and ASGI integration tests use function-scoped fixtures in `tests/conftest.py`.

For local database work, start PostgreSQL with `docker compose up -d`; the password variable is `STOCK_DB_PASSWORD`. Kubernetes deployment manifests are under `deploy/`. Tests must use isolated data and must not target production.

## Product documentation

Work items use Jira Cloud, for example [STK-12](https://stock-team.atlassian.net/browse/STK-12). The team runbook is in [Confluence](https://stock-team.atlassian.net/wiki/spaces/STOCK/pages/1042/Stock+API+Runbook). These links identify the documented host only; credentials are configured outside the repository.
