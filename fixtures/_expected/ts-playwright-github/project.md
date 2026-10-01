# Project Context — Catalogue Web

## Summary
High confidence: TypeScript storefront backed by a catalogue HTTP contract. Sources: `README.md:3`, `docs/openapi.yaml:8`.

## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| Catalogue browser | web client | `src/` | TypeScript / Vite | Render catalogue products |
| Catalogue API boundary | HTTP contract | `docs/openapi.yaml` | REST | List products |
| API and UI checks | test suites | `tests/api/`, `tests/e2e/` | Playwright | Verify route response and browser states |
Sources: `src/main.ts:4`, `docs/openapi.yaml:8`, `tests/api/catalogue.spec.ts:12`, `tests/e2e/catalogue.spec.ts:13`.

## Technology stack
High confidence: Node.js 22, TypeScript, Vite, Playwright. Sources: `README.md:7`, `package.json:7`, `package.json:12`.

## Environments
Medium confidence: local browser app uses localhost:3000; deployment URL is not found. Sources: `README.md:7`, `playwright.config.ts:14`.

## Data stores and external dependencies
Medium confidence: PostgreSQL is documented for local service development, but the browser tests mock HTTP and no backend source is present. Sources: `compose.yaml:3`, `docs/adr/0001-catalogue-api.md:13`.

## CI/CD
High confidence: GitHub Actions installs dependencies, installs Chromium and runs Playwright on push/PR. Sources: `.github/workflows/tests.yml:2`, `.github/workflows/tests.yml:17`.

## Test landscape
High confidence: Playwright API path `tests/api/`, browser path `tests/e2e/`, JUnit report at `test-results/junit.xml`. Sources: `package.json:8`, `package.json:9`, `playwright.config.ts:8`.

## Constraints
High confidence: tests should use Playwright route fixtures rather than shared services. Source: `CONTRIBUTING.md:11`.

## Documentation sources
High confidence: README, OpenAPI, and ADR are local. Sources: `README.md:3`, `docs/openapi.yaml:1`, `docs/adr/0001-catalogue-api.md:1`.

## Unknowns and conflicts
Medium confidence: production API implementation and deploy URL are not present; repository remote and provider access are unchecked. Source: `discovery.md`.

## Provenance
High confidence: local fixture snapshot; no remote GitHub probe or test execution. Sources: `.github/workflows/tests.yml:17`, `README.md:7`.
