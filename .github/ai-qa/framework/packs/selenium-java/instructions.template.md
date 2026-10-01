---
description: Project-adapted Selenium Java conventions (template; inactive in this location)
applyTo: "{{globs}}"
---

# Selenium Java instructions template

Narrow `applyTo` to the confirmed Selenium test package before copying to project conventions. This glob overlaps Cucumber and JUnit API tests; never apply unrelated Java packs together.

- Encapsulate stable ID/CSS locators and interactions in page objects; avoid absolute XPath.
- Use explicit state waits, not sleeps or mixed implicit/explicit waits.
- Isolate driver lifecycle per test with reliable cleanup; avoid shared static drivers.
- Assert observable outcomes with the project's assertion library; never hardcode secrets or driver paths.

## Locators / selectors
Use stable IDs/CSS encapsulated by page objects; avoid absolute XPath.
## Waiting & synchronisation
Explicit WebDriver waits, no sleeps or mixed implicit waits.
## Assertions
Assert user-visible behavior with project assertion library.
## Structure & fixtures
Isolate browser driver per test and always quit.
## Test data
Use environment-approved accounts and independent data.
## Anti-patterns
Avoid shared static drivers, raw DOM access in tests and hardcoded paths.
