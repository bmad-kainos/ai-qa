---
description: Project-adapted JUnit 5 and REST Assured API test conventions (template; inactive in this location)
applyTo: "{{globs}}"
---

# JUnit 5 + REST Assured instructions template

Narrow `applyTo` to the confirmed API test package before copying to the approved project conventions layer: this glob also matches Selenium/Cucumber Java tests. Require both JUnit Jupiter and REST Assured in the existing build.

- Use `@Test` / `@ParameterizedTest` with descriptive names for independent contract cases.
- Reuse existing request/response specifications and builders, with fresh per-test data; do not mutate global base URI/auth across parallel tests.
- Assert only documented statuses, headers and response content; distinguish unsupported/unknown cases from passing tests.
- Get base URL and auth from approved test configuration; redact request/response logs and never embed secrets.
- Do not add libraries, run state-changing tests or target production merely because a template exists.

## Locators / selectors
Use contract-backed JSON paths/headers, not DOM locators.
## Waiting & synchronisation
No arbitrary sleeps; assert synchronous responses or confirmed async completion signals.
## Assertions
Assert documented status, headers and body using installed matchers/validators.
## Structure & fixtures
JUnit Jupiter lifecycle and project request/response specs; avoid mutable global state.
## Test data
Fresh per-case builders and isolated cleanup; auth stays in approved configuration.
## Anti-patterns
Avoid guessed statuses, credential logging and concurrent shared mutable request specs.
