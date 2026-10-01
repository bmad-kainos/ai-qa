# Project Context — Catalogue web

<!-- ai-qa:managed -->
## Summary
High: TypeScript catalogue application ([README](../../fixtures/typescript-github/README.md)).
## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| Catalogue API | HTTP endpoint | `docs/openapi.yaml` | REST | List items |
| API tests | test suite | `tests/api/` | Playwright | Validate endpoint |
## Technology stack
High: TypeScript and Playwright ([package](../../fixtures/typescript-github/package.json)).
## Environments
Medium: local base URL default; deployed URL supplied by `TEST_BASE_URL` ([config](../../fixtures/typescript-github/playwright.config.ts)).
## Data stores and external dependencies
Low: no data store documented ([README](../../fixtures/typescript-github/README.md)).
## CI/CD
High: GitHub Actions test job ([workflow](../../fixtures/typescript-github/.github/workflows/tests.yml)).
## Test landscape
High: one API test and JUnit reporter ([test](../../fixtures/typescript-github/tests/api/catalogue.spec.ts), [config](../../fixtures/typescript-github/playwright.config.ts)).
## Constraints
Low: no specific constraints documented ([README](../../fixtures/typescript-github/README.md)).
## Documentation sources
High: [README](../../fixtures/typescript-github/README.md), [OpenAPI](../../fixtures/typescript-github/docs/openapi.yaml).
## Unknowns and conflicts
Medium: base branch, deployed environments and data storage are unconfirmed ([discovery](discovery.md)).
## Provenance
High: local fixture files; no remote PR or test execution evidence.
<!-- ai-qa:user -->
Preserved project notes.
