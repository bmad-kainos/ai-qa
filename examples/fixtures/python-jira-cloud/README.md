# Stock API

Python API tested with pytest and httpx. Run `python -m pytest tests/` and set `TEST_BASE_URL` for deployed integration tests. For the local database set `STOCK_DB_PASSWORD` before starting Compose. Work items live at `https://stock-team.atlassian.net/browse/STOCK-123` (example hostname; do not infer authentication from it). Tests use function-scoped fixtures and JUnit output configured in `pyproject.toml`.
