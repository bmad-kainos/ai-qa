---
description: Project-adapted pytest Python test conventions (template; inactive in this location)
applyTo: "{{globs}}"
---

# pytest Python instructions template

Adapt the globs and copy to the approved project conventions layer only if the runner is confirmed. Follow the existing client library and fixtures; do not assume `pytest-playwright` or an HTTP library exists.

- Arrange–Act–Assert; behavior/outcome test names, one independent behavior per case.
- Use narrow fixtures in `conftest.py`; session scope only for read-only shared resources.
- Parameterize meaningful boundaries, with `ids` for ambiguous inputs; register custom markers.
- Include expected/actual/input in nontrivial failures; assert contract-defined error body as well as status.
- No sleeps, real network in unit tests, shared mutable fixtures or embedded credentials.

## Locators / selectors
For pytest-playwright only, use semantic locators if the plugin is installed; otherwise not applicable.
## Waiting & synchronisation
Use explicit observable readiness; no sleeps or order-dependent setup.
## Assertions
Assert documented outcomes with informative expected/actual/input messages.
## Structure & fixtures
Use narrowly scoped `conftest.py` fixtures and established test roots.
## Test data
Build independent inputs per test and parameter row; keep auth outside source.
## Anti-patterns
Avoid shared mutable fixtures, live unit-test network and invented markers.
