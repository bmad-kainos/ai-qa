# ADR 0001: Package test ownership

## Status

Accepted

## Decision

Keep API contract tests in `packages/api/tests/api` and browser-domain unit tests in `packages/web/tests`. Each package owns its runner and package-local test configuration; root scripts compose both suites.

## Consequences

Discovery and configuration must preserve package paths. AI-QA v1 supports one test scope path per configuration, so a user must select the package scope before rendering instructions.