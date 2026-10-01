---
name: pytest + Python test conventions
description: Best practices for pytest test suites in Python.
applyTo: "{{globs}}"
---

# pytest + Python — test conventions

> Rendered by `qa-configure` for this project's selected test paths only. The project's `.github/ai-qa/project/conventions/testing.md` and neighbouring tests take precedence over this pack guidance (precedence: user instruction > project conventions > neighbouring code > pack > framework defaults).

## Structure
- Arrange–Act–Assert; one behaviour per test.
- Name tests `test_<what>_<expected_outcome>`; group related cases in a `Test<Thing>` class.

## Fixtures
- Put shared fixtures in `conftest.py`. Use the narrowest scope that is correct; `scope="session"` only for read-only shared resources.
- Never share mutable state between tests; spread dicts (`{**BASE, ...}`) instead of mutating a shared object.

## Parametrisation
- Use `@pytest.mark.parametrize` with `ids=` when values aren't self-describing.
- Cover the min boundary, max boundary, a valid mid value, and an invalid value.

## Assertions
- Non-trivial assertions carry a message stating expected, received, and the parametrised value(s).

## Markers
- Register markers in config; use them to select levels (`unit`, `integration`, `e2e`).

## Anti-patterns
- No `time.sleep()`; no network in unit tests; no order-dependent tests; no `print()` (use `-s`); no secrets in test files.

## Playwright + Python — test conventions

Uses `pytest-playwright` (the `page` fixture). Also follow the pytest conventions.

### Locators
- Use role-based locators: `page.get_by_role`, `get_by_label`, `get_by_text`.
- Avoid CSS/XPath; use `get_by_test_id` only as a fallback.

### Waiting & synchronisation
- Never `page.wait_for_timeout()`. Rely on auto-waiting.
- Use `from playwright.sync_api import expect` then `expect(locator).to_be_visible()` — it auto-retries.

### Assertions
- Prefer `expect(locator).to_have_text(...)` over manual `assert locator.text_content()`.

### Structure & fixtures
- Use pytest fixtures for setup; keep tests isolated and parallel-safe (`pytest-xdist`).
- Reuse authentication via `storage_state`.

### Network
- Mock with `page.route`; check backend calls with the `request` context.

### Anti-patterns
- No hard waits, no CSS/XPath, no shared mutable state, no secrets in code.
