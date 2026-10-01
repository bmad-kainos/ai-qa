# Discovery — python-jira-cloud

| Domain | Status | Conclusion | Evidence | Note |
|---|---|---|---|---|
| Build/test | ✓ Observed | Python, pytest and httpx | `pyproject.toml:1-12`, `tests/test_stock.py:1-3` | One test sampled, 1/1 `test_*.py`. |
| Execution | ✓ Observed | `python -m pytest tests/`, JUnit report | `README.md:3`, `pyproject.toml:9-12` | No run performed. |
| Data | ✓ Observed | Postgres Compose service | `compose.yaml:1-6` | Env var name only, never collect value. |
| Jira | ◐ Inferred | `*.atlassian.net` suggests Cloud | `README.md:3` | Confirm via `serverInfo` read-only if available. |
| Documentation | ✓ Observed | Stock/checkout service boundary | `docs/adr/0001-stock-source.md:1-3` | No configured remote docs space. |
| PR conventions | ∅ Not found | No template | Fixture scan | Default only after Configure confirmation. |

Sample: one test (1/1 naming match), manifest, README, ADR and Compose. Examples: `tests/test_stock.py:1`, `pyproject.toml:10`, `docs/adr/0001-stock-source.md:3`.

## Needs your input

- Is the inferred Jira Cloud deployment correct if a read-only probe cannot be performed?
- Which checkout sandbox is available for cross-service tests?
