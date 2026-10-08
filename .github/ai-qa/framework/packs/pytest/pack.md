| Field | Value |
|---|---|
| id | `pytest` |
| tier | `full` |
| languages | Python |
| levels | Unit, API integration, browser/API E2E |
| detection signals | pytest in project manifest/config, `conftest.py`, representative pytest tests; inspect dependencies to distinguish `requests`, `httpx` and `pytest-playwright` |
| default paths | `tests/unit/test_*.py`, `tests/integration/test_*.py`, `tests/e2e/test_*.py` (only absent project conventions) |
| run by path | `pytest "<path-or-node-id>"` (template only; use configured `Commands` first) |
| run by tag | `pytest -m "<registered-marker>"` (marker must already be registered) |
| report format | Configured JUnit XML and/or pytest JSON report, plus command, environment and evidence in `09_execution.md` |
| anti-patterns | Sleeps, shared mutable fixtures, network in unit tests, unregistered markers, order-dependent tests, debug prints, secrets |

Select when repository evidence confirms pytest. Inspect existing client and fixtures to distinguish `requests`, `httpx` and Playwright Python; never install or assume a client/plugin.

## Workflow
1. Inspect `conftest.py`, marker registration, fixtures, client library and representative tests. Classify pure logic as unit, one API exchange as integration and a multi-step journey as E2E.
2. Present a requirement/contract-linked inventory before code. Derive response expectations only from authoritative requirements or contracts.
3. Match the existing test root, file/function naming and class style. Suggested default paths are not mandatory.
4. Use Arrange–Act–Assert, narrow fixtures and fresh mutable payloads. Session scope is for read-only resources only; keep network out of unit tests.
5. Use `@pytest.mark.parametrize` and readable `ids`; register custom markers only through approved project configuration. Assert documented status and error body, with expected/actual/input in meaningful failure messages.
6. For Playwright Python, use its established `page` fixture and semantic locators; for API tests, use the project's existing client fixture/library.
7. Use documented targeted validation only when permitted; distinguish generated from executed and passing tests.
