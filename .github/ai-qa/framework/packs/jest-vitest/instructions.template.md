---
description: Project-adapted Jest or Vitest TypeScript conventions (template; inactive in this location)
applyTo: "{{globs}}"
---

# Jest / Vitest TypeScript instructions template

Choose the *installed* runner and narrow globs before copying to project conventions; Jest/Vitest mock APIs are not interchangeable. Avoid overlapping Playwright test files.

- Arrange–Act–Assert one behavior per test with specific equality/error matchers.
- Await promise assertions; mock only external boundaries and restore mocks between tests.
- Build fresh test data; avoid shared state, broad snapshots, live unit-test network and secrets.

## Locators / selectors
For component tests follow installed library's accessible selectors; pure unit tests have none.
## Waiting & synchronisation
Await promise assertions; avoid sleeps.
## Assertions
Use specific structural, identity and error matchers for observable behavior.
## Structure & fixtures
Use the configured runner and restore mocks between isolated tests.
## Test data
Fresh factories and boundary values; no credentials or live network in units.
## Anti-patterns
Avoid mixing Jest/Vitest APIs, broad snapshots and order dependencies.
