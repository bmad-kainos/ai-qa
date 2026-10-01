# Project Context — Orders Service

## Summary
High confidence: Java 21 Orders REST API; PostgreSQL is named as its system of record. Sources: `README.md:3`, `README.md:7`.

## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| Orders API | service | `src/main/java/com/kainos/commerce/orders/` | Spring Boot / REST | Create and retrieve orders |
| API tests | test suite | `src/test/java/com/kainos/commerce/orders/` | JUnit 5 / RestAssured | Validate create and invalid-quantity responses |
| Orders database | data store | `compose.yaml` | PostgreSQL 16 | Local dependency; deployed persistence status unresolved |
Sources: `docs/openapi.yaml:1`, `src/test/java/com/kainos/commerce/orders/OrderApiTest.java:24`, `compose.yaml:3`.

## Technology stack
High confidence: Maven, Java 21, Spring Boot, JUnit 5, RestAssured. Sources: `pom.xml:11`, `README.md:7`, `src/test/java/com/kainos/commerce/orders/OrderApiTest.java:3`.

## Environments
Medium confidence: local API uses a random test port; Compose provides PostgreSQL. Staging is an Azure Pipelines environment hand-off. Sources: `src/test/java/com/kainos/commerce/orders/OrderApiTest.java:14`, `compose.yaml:3`, `azure-pipelines.yml:26`.

## Data stores and external dependencies
Medium confidence: PostgreSQL is documented, but current controller state is in-memory. This is a material conflict, not a confirmed persistence path. Sources: `README.md:3`, `docs/architecture.md:3`, `src/main/java/com/kainos/commerce/orders/OrderController.java:17`.

## CI/CD
High confidence: Azure Pipelines runs Maven tests and publishes JUnit XML before the main-branch staging hand-off. Sources: `azure-pipelines.yml:18`, `azure-pipelines.yml:22`, `azure-pipelines.yml:26`.

## Test landscape
High confidence: two JUnit 5 + RestAssured API tests in one class; command is `sh mvnw --batch-mode test`. Sources: `src/test/java/com/kainos/commerce/orders/OrderApiTest.java:24`, `src/test/java/com/kainos/commerce/orders/OrderApiTest.java:37`, `CONTRIBUTING.md:11`.

## Constraints
Medium confidence: tests should be deterministic and isolated; integration tests must not target staging. Sources: `CONTRIBUTING.md:11`, `docs/adr/0001-postgres.md:13`.

## Documentation sources
High confidence: local README, OpenAPI, architecture note, and ADR. Sources: `README.md:3`, `docs/openapi.yaml:1`, `docs/architecture.md:1`, `docs/adr/0001-postgres.md:1`.

## Unknowns and conflicts
High confidence: persistence implementation and Azure DevOps access/project identity require confirmation; no PR template or remote docs root is present. Sources: `discovery.md`, `README.md:11`.

## Provenance
High confidence: local fixture files and source samples only; no test execution, authenticated provider probe, or remote PR review. Sources: `azure-pipelines.yml:18`, `CONTRIBUTING.md:7`.
