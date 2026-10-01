# Discovery — Orders Service

Scope: complete fixture snapshot. Sampled README, Maven manifest/wrapper, both API tests, pipeline, OpenAPI, Compose, Terraform, architecture notes and ADR. Test sample: 2/2 methods in 1/1 test files use JUnit `@Test`; no suite was run. A fixture snapshot cannot establish current remote permissions or recent PR history.

| Domain | Status | Finding | Evidence | Note |
|---|---|---|---|---|
| Identity and ownership | ✓ Observed | Orders Service is a Java 21 REST API. | `README.md:3` | Team ownership is not named. |
| Architecture and interfaces | ✓ Observed | Orders API has create/retrieve operations; OpenAPI contract is present. | `docs/openapi.yaml:1`, `README.md:3` | No auth scheme is specified. |
| Stack and build | ✓ Observed | Maven project, Java 21, Spring Boot, JUnit 5 and RestAssured. | `pom.xml:11`, `README.md:7`, `src/test/java/com/kainos/commerce/orders/OrderApiTest.java:3` | Gradle files are not part of the intended build. |
| Source and documentation layout | ✓ Observed | Java source under `src/main/java`; ADR and architecture notes under `docs/`. | `docs/architecture.md:3`, `docs/adr/0001-postgres.md:1` | — |
| Test inventory and conventions | ✓ Observed | Two random-port API cases share a JUnit test class. | `src/test/java/com/kainos/commerce/orders/OrderApiTest.java:14`, `src/test/java/com/kainos/commerce/orders/OrderApiTest.java:24` | 2/2 sampled tests are API boundary tests. |
| Fixtures and test data | ◐ Inferred | Request payloads are inline JSON; a database fixture is not wired to the tests. | `src/test/java/com/kainos/commerce/orders/OrderApiTest.java:27`, `compose.yaml:3` | Basis: one sampled test class and local Compose definition. |
| Data and external boundaries | ⚠ Conflict | README calls PostgreSQL the system of record; architecture says it is intended for deployed use while controller example state is in-memory. | `README.md:3`, `docs/architecture.md:3`, `src/main/java/com/kainos/commerce/orders/OrderController.java:17` | Confirm whether persistence exists outside this fixture implementation. |
| Environments and deployment | ✓ Observed | Compose exposes local PostgreSQL; pipeline defines a protected staging deployment hand-off. | `compose.yaml:3`, `azure-pipelines.yml:26` | Actual release task is outside the repository. |
| CI and validation | ✓ Observed | Pipeline runs `sh mvnw --batch-mode test` and publishes Surefire JUnit XML. | `azure-pipelines.yml:18`, `azure-pipelines.yml:22` | No test run performed. |
| Git and review | ✓ Observed | `main`, feature/bugfix branch forms, Conventional Commits, and `AB#123` are documented. | `CONTRIBUTING.md:6`, `CONTRIBUTING.md:7` | No PR template or recent PR sample. |
| Requirements and work items | ◐ Inferred | Azure Boards is indicated by the dev.azure.com URL and `AB#123` syntax. | `README.md:11`, `CONTRIBUTING.md:7` | Remote organisation/project access not probed. |
| Docs and ADRs | ✓ Observed | OpenAPI and PostgreSQL ownership decisions are local. | `README.md:3`, `docs/adr/0001-postgres.md:9` | No named remote documentation root. |
| QA reporting and observability | ∅ Not found | No application telemetry, QA dashboard, or report audience convention found in the bounded fixture scan. | `azure-pipelines.yml:22` | JUnit is the only report output observed. |
| Remote access | ? Could not check | Azure DevOps identity, PR history and provider permissions cannot be checked from fixture files. | Read-only fixture inspection | No authenticated remote probe performed. |

## Needs your input

- Confirm the Azure DevOps organisation/project and available read-only transport before configuring work-item or PR operations.
- Is PostgreSQL connected to the implementation, or is the in-memory controller the current behaviour?
