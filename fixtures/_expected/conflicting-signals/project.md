# Project Context — Pricing Service

## Summary
High confidence: TypeScript pricing service with deliberately unresolved test-runner and work-tracking decisions. Sources: `README.md:3`, `CONTRIBUTING.md:9`.

## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| Pricing unit tests | test suite | `tests/unit/` | Vitest (manifest/config) vs Jest (guide) | Price rule checks |
| Pricing integration tests | test suite | `tests/integration/` | Playwright | HTTP price validation |
Sources: `package.json:6`, `vitest.config.ts:5`, `playwright.config.ts:4`, `tests/integration/orders.spec.ts:3`.

## Technology stack
Medium confidence: TypeScript, Vitest and Playwright are present; CONTRIBUTING instead claims Jest. Sources: `package.json:6`, `package.json:8`, `CONTRIBUTING.md:9`.

## Environments
Medium confidence: integration test URL defaults to localhost:4100 and can be overridden by `PRICING_API_URL`. Source: `playwright.config.ts:6`.

## Data stores and external dependencies
Low confidence: no store or third-party service is described in local source. Source: `README.md:3`.

## CI/CD
Medium confidence: GitHub Actions runs only the root `npm test` script; no integration step is observed. Sources: `.github/workflows/tests.yml:1`, `package.json:6`.

## Test landscape
High confidence: Vitest unit tests use `.test.ts`; Playwright integration tests use `.spec.ts`; the project guide says Jest. Sources: `tests/unit/pricing.test.ts:1`, `tests/integration/orders.spec.ts:1`, `CONTRIBUTING.md:9`.

## Constraints
Medium confidence: integration test target and provider ownership need confirmation; no secrets are present. Sources: `playwright.config.ts:6`, `docs/adr/0001-legacy-tracker.md:13`.

## Documentation sources
High confidence: README, CONTRIBUTING, PR template and tracker ADR are local. Sources: `README.md:3`, `CONTRIBUTING.md:1`, `.github/PULL_REQUEST_TEMPLATE.md:1`, `docs/adr/0001-legacy-tracker.md:1`.

## Unknowns and conflicts
High confidence: Jest vs Vitest, Jira vs Azure Boards/GitHub issue syntax, and unit/integration runner ownership are unresolved. Sources: `CONTRIBUTING.md:5`, `CONTRIBUTING.md:9`, `README.md:3`, `docs/adr/0001-legacy-tracker.md:13`.

## Provenance
High confidence: local fixture snapshot; no tests or remote provider probes were run. Sources: `.github/workflows/tests.yml:1`, `discovery.md`.
