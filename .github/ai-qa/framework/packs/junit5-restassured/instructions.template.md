---
name: JUnit 5 + REST Assured test conventions
description: Best practices for JUnit 5 and REST Assured API tests written in Java or Kotlin.
applyTo: "{{globs}}"
---

# JUnit 5 + REST Assured — API test conventions

## Locators / selectors
- Use contract-backed JSON paths/headers, not DOM locators.

## Waiting & synchronisation
- No arbitrary sleeps; assert synchronous responses or confirmed async completion signals.

## Assertions
- Use AssertJ or JUnit assertions with clear messages.
- Assert status, relevant headers and response data using existing matchers/JSON schema validator where installed.

## Structure & fixtures
- Use JUnit 5 `@Test` or `@ParameterizedTest` with readable display names; fresh test data/builders per case.
- Keep REST Assured request/response specifications in existing shared setup; use per-request data and isolated cleanup rather than mutable global base URI or shared credentials.

## Test data
- Use fresh test data/builders per case.
- Avoid logging sensitive bodies, tokens or PII.

## Anti-patterns
- Avoid mutable global request/auth/base URI, unsafe destructive tests, credential logging, guessed statuses.
- No secrets in test source.

## Feabhas template notes
Narrow `applyTo` to the confirmed API test package before copying to the approved project conventions layer: this glob also matches Selenium/Cucumber Java tests. Require both JUnit Jupiter and REST Assured in the existing build.
- Use `@Test` / `@ParameterizedTest` with descriptive names for independent contract cases.
- Reuse existing request/response specifications and builders, with fresh per-test data; do not mutate global base URI/auth across parallel tests.
- Assert only documented statuses, headers and response content; distinguish unsupported/unknown cases from passing tests.
- Get base URL and auth from approved test configuration; redact request/response logs and never embed secrets.
- Do not add libraries, run state-changing tests or target production merely because a template exists.

The project's `.github/ai-qa/project/conventions/testing.md` takes precedence.
