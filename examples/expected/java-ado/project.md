# Project Context — Orders Service

<!-- ai-qa:managed -->
## Summary
High confidence: Java Orders API backed by PostgreSQL ([README](../../fixtures/java-ado/README.md)).
## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| Orders API | service | `docs/openapi.yaml` | REST/Java | Fetch orders |
| Database | data store | `compose.yaml` | PostgreSQL | Persist orders |
## Technology stack
High: Gradle, JUnit 5, RestAssured ([manifest](../../fixtures/java-ado/build.gradle.kts)).
## Environments
Medium: local Compose database; deployed environments unspecified ([Compose](../../fixtures/java-ado/compose.yaml)).
## Data stores and external dependencies
High: PostgreSQL ([Compose](../../fixtures/java-ado/compose.yaml)).
## CI/CD
High: Azure Pipelines unit test job ([pipeline](../../fixtures/java-ado/azure-pipelines.yml)).
## Test landscape
Medium: JUnit dependencies and JUnit report path; no test sources in fixture ([manifest](../../fixtures/java-ado/build.gradle.kts)).
## Constraints
Medium: isolated database fixtures ([ADR](../../fixtures/java-ado/docs/adr/0001-postgres.md)).
## Documentation sources
High: [README](../../fixtures/java-ado/README.md), [API](../../fixtures/java-ado/docs/openapi.yaml), [ADR](../../fixtures/java-ado/docs/adr/0001-postgres.md).
## Unknowns and conflicts
High: README mentions integration test task missing from manifest; Azure organisation unknown ([discovery](discovery.md)).
## Provenance
High: local fixture files only; no remote provider probe or test execution.
<!-- ai-qa:user -->
Project-specific notes belong here; refresh must preserve this section.
