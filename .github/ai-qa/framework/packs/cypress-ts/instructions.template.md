---
description: Project-adapted Cypress TypeScript conventions (template; inactive in this location)
applyTo: "{{globs}}"
---

# Cypress TypeScript instructions template

Narrow globs to confirmed Cypress test/support roots before copying to project conventions. Do not conflate Cypress and Playwright config or test APIs.

- Select stable `data-cy` or installed role queries over layout selectors.
- Use Cypress retrying assertions and aliased intercepted requests; no `cy.wait(number)` sleeps.
- Do not assign queued command values or mix `async/await` with Cypress command chains.
- Reset state between tests; use approved auth/configuration and non-sensitive fixtures.

## Locators / selectors
Prefer stable data attributes or installed role queries.
## Waiting & synchronisation
Use retrying commands/assertions and aliased intercepts, not numeric waits.
## Assertions
Assert visible outcomes through `.should(...)`.
## Structure & fixtures
Reset state in `beforeEach`, follow project support and spec layout.
## Test data
Use approved non-sensitive fixtures and independent seeds.
## Anti-patterns
Avoid mixed async command chains and shared mutable test state.
