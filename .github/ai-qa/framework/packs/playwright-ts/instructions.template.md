---
description: Project-adapted Playwright TypeScript test conventions (template; inactive in this location)
applyTo: "{{globs}}"
---

# Playwright TypeScript instructions template

Copy/adapt into the approved project conventions layer only after confirming Playwright is the project's runner. Narrow `applyTo` to actual test roots to avoid colliding with Jest/Vitest specs. Follow existing imports, fixtures, config and naming.

- Use accessible role/label locators; test IDs only when needed, never positional CSS/XPath by default.
- Use auto-waiting and awaited web-first assertions; wait for a specific response or state, not a sleep.
- Keep tests isolated and parallel-safe; fresh data factories and `test.extend` fixtures.
- Prefer the `request` fixture for HTTP contract tests and `page` for actual UI journeys.
- Read auth/base URL from approved configuration. Never embed secrets, assume production is safe or claim unrun tests passed.

## Locators / selectors
Prefer semantic role and label queries; limit test IDs to elements without stable accessible handles.
## Waiting & synchronisation
Use action auto-waiting, retrying assertions and specific response/state signals; no sleeps.
## Assertions
Await `expect` and assert observable results and contract-backed statuses.
## Structure & fixtures
Match project test paths; use isolated `test.extend` fixtures and fresh payloads.
## Test data
Use per-test data and approved environment-specific auth without embedding credentials.
## Anti-patterns
Avoid positional selectors, hard waits, shared mutable state and unverified result claims.
