# pytest + Python — full pack

**ID:** `pytest` · **Tier:** full · **Template:** [instructions.template.md](instructions.template.md) · **Generation:** [generation.md](generation.md)

| Field | Value |
|---|---|
| id / tier / languages / levels | `pytest` / `full` / Python / unit, API integration, E2E |
| Detection signals | `pytest` in manifest/config, `conftest.py` and representative pytest tests |
| Default paths (only if no project convention) | `tests/unit/test_*.py`, `tests/integration/test_*.py`, `tests/e2e/test_*.py` |
| Run by path/tag | Existing pytest runner with specific file/node ID; registered `-m <marker>` for existing tags |
| Report | Cases, command, environment, observed results and evidence in approved `qa-work/<id>/` after L1 |
| Anti-patterns | Sleeps, session-scoped mutable fixtures, live network in unit tests, unregistered markers, secrets |

Select when project files confirm pytest (`pyproject.toml`, `pytest.ini` or existing `test_*.py` using pytest). Distinguish plain pytest API tests from `pytest-playwright`; use its `page` fixture only if already installed/configured.

## Workflow
1. Inspect existing `conftest.py`, marker registration, fixtures, client library and tests. Classify pure logic as unit, a single API exchange as integration, and chained multi-system journeys as E2E.
2. List cases tied to requirements/contract and expected results. For REST APIs derive cases from an authoritative endpoint/OpenAPI contract; do not assume 400 versus 422, auth type or schema without a source.
3. Match the project's test root. If none is established, *suggest* `tests/unit/test_<concern>.py`, `tests/integration/test_<resource>_contract.py`, `tests/e2e/test_<journey>.py` and `tests/conftest.py`. Use `test_<behavior>_<outcome>`; group related concerns in `Test<Concern>`.
4. Arrange–Act–Assert, one behavior per test; use narrowly scoped fixtures, with session scope only for read-only resources. Build fresh mutable payloads per invocation; keep network out of unit tests. A configured client fixture should own base URL, auth and cleanup; never hardcode credentials.
5. Use `@pytest.mark.parametrize` and readable `ids` for boundaries/equivalence classes. Register custom markers before use; apply ticket markers only if the repository already does so. Assert status **and** error body when the contract defines them; nontrivial failure messages identify expected, actual and input values.
6. For `pytest-playwright`, prefer `page.get_by_role` / `get_by_label` and auto-retrying `expect(locator).to_be_visible()`; never `wait_for_timeout()`. For API calls use the project's existing client fixture/library, not an invented one.
7. Run an existing targeted test selector if available; distinguish generated/unrun from executed/passing tests.

Avoid `time.sleep`, shared mutable fixtures, order-dependent tests, accidental live network, debug prints and secrets in source.
