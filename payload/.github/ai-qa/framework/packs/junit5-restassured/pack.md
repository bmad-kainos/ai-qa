| Field | Value |
|---|---|
| id | `junit5-restassured` |
| tier | `full` |
| languages | Java, Kotlin |
| levels | Unit, API integration, E2E |
| detection signals | JUnit Jupiter and REST Assured dependencies, Maven/Gradle configuration, and representative API tests |
| default paths | Package-matched test classes under `src/test/java/**` (only absent project conventions) |
| run by path | Maven: `./mvnw -Dtest="<ClassOrMethod>" test`; Gradle: `./gradlew test --tests "<fully.qualified.Class>"` (templates only) |
| run by tag | Maven: `./mvnw -Dgroups="<tag>" test`; Gradle: `./gradlew test -DincludeTags="<tag>"` (only when project runner is configured for JUnit tags) |
| report format | Existing JUnit XML/Surefire or Gradle test report, plus command, environment and evidence in `execution.md` |
| anti-patterns | Mutable global request/auth/base URI, unsafe destructive tests, credential logging, guessed statuses, new dependencies without approval |

Select only when repository evidence confirms both JUnit Jupiter and REST Assured. Match the existing language, package, build runner, fixtures, serializers, auth and naming. Do not add dependencies or assume the environment.

## Workflow
1. Inspect the authoritative requirement/OpenAPI source, representative tests, environment configuration and existing specifications/builders.
2. Present an inventory of method/path, parameters, request fields, documented responses, content types and security; resolve references or label unknowns.
3. Separate pure logic, single-call API integration and multi-step journeys. Derive assertions only from documented behavior.
4. Use JUnit 5 tests/parameterised tests and fresh per-case payload builders; reuse existing REST Assured specifications without mutable global per-test state.
5. Assert documented statuses, headers and body with already-installed matchers/validators. Do not log secrets or perform unsafe operations.
6. Use only the project's targeted Maven/Gradle command; present generated, compiled, executed and passed results separately.
