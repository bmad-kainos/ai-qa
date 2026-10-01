---
description: Project-adapted Cucumber Java conventions (template; inactive in this location)
applyTo: "{{globs}}"
---

# Cucumber Java instructions template

Narrow globs to observed feature/glue roots before copying to project conventions. Confirm runner and scenario-state wiring rather than assuming a DI library.

- Write declarative behavior, one outcome per scenario; use outlines for meaningful variants.
- Keep step definitions thin and reusable; share state via existing scenario-scoped wiring, never static globals.
- Limit Background, tags and hooks to actual project needs; keep tests isolated and cleanup reliable.
- Avoid credentials in features and UI-click implementation detail in scenarios.

## Locators / selectors
No locators in Gherkin; delegate UI access to existing page objects in glue.
## Waiting & synchronisation
Wait for meaningful outcomes in delegated helpers, never arbitrary sleeps.
## Assertions
Express expected business outcomes in scenarios; verify in step definitions.
## Structure & fixtures
Thin reusable glue, scenario-scoped state and minimal hooks.
## Test data
Examples tables for meaningful variations and independent scenario data.
## Anti-patterns
Avoid static state, imperative UI steps and giant Background sections.
