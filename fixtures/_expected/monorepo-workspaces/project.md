# Project Context — Commerce workspace

## Summary
High confidence: npm monorepo with independently tested Orders API and storefront packages. Sources: `README.md:3`, `package.json:4`.

## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| Orders API | package/API | `packages/api/` | Playwright / REST | Validate Orders endpoint |
| Storefront | package/web | `packages/web/` | Vitest | Validate web-domain calculations |
Sources: `packages/api/tests/api/orders.spec.ts:1`, `packages/web/tests/cart.test.ts:1`, `docs/adr/0001-workspace-boundaries.md:9`.

## Technology stack
High confidence: npm workspaces; Playwright in API package; Vitest in web package. Sources: `package.json:4`, `packages/api/package.json:5`, `packages/web/package.json:5`.

## Environments
Medium confidence: API tests target `ORDERS_API_URL`, default localhost:8080; deployed environment is not identified. Source: `packages/api/playwright.config.ts:5`.

## Data stores and external dependencies
Low confidence: no database or external service is declared in the bounded fixture scan. Source: `README.md:3`.

## CI/CD
High confidence: GitHub Actions installs root workspace dependencies and runs both root test scripts. Sources: `.github/workflows/tests.yml:2`, `.github/workflows/tests.yml:16`.

## Test landscape
High confidence: Playwright API tests live under `packages/api/tests/api`; Vitest tests live under `packages/web/tests`; root `npm test` runs both. Sources: `packages/api/playwright.config.ts:4`, `packages/web/vitest.config.ts:4`, `README.md:7`.

## Constraints
High confidence: package paths and runners are independently owned. AI-QA v1 supports one scope path at a time, so configure one package per run. Sources: `docs/adr/0001-workspace-boundaries.md:9`, `README.md:3`.

## Documentation sources
High confidence: README, CONTRIBUTING, OpenAPI and package-boundary ADR. Sources: `README.md:3`, `CONTRIBUTING.md:1`, `docs/openapi.yaml:1`, `docs/adr/0001-workspace-boundaries.md:1`.

## Unknowns and conflicts
Medium confidence: first configured package, provider identity and non-production API target need confirmation. Sources: `README.md:3`, `packages/api/playwright.config.ts:5`, `discovery.md`.

## Provenance
High confidence: local fixture files and one test per package; no test execution or remote provider probe. Sources: `packages/api/tests/api/orders.spec.ts:1`, `packages/web/tests/cart.test.ts:1`.