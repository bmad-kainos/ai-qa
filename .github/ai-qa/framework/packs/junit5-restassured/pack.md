# JUnit 5 + REST Assured — full pack

**ID:** `junit5-restassured` · **Tier:** full · **Template:** [instructions.template.md](instructions.template.md) · **Generation:** [generation.md](generation.md)

| Field | Value |
|---|---|
| id / tier / languages / levels | `junit5-restassured` / `full` / Java / unit, API integration, E2E |
| Detection signals | JUnit Jupiter and REST Assured dependencies plus representative API tests |
| Default paths (only if no project convention) | `src/test/java/**` package-matched API test classes |
| Run by path/tag | Existing Maven/Gradle class/method selector; existing JUnit `@Tag` filtering only if configured |
| Report | Cases, selected command, environment and observed assertions in approved `qa-work/<id>/` after L1 |
| Anti-patterns | Mutable global request/auth/base URI, unsafe destructive tests, credential logging, guessed statuses |

Select only when a Java project actually uses JUnit Jupiter and REST Assured (inspect Maven/Gradle manifests, existing tests and configuration). Do not introduce dependencies or assume an endpoint/test environment. Match the existing package, build runner, fixtures, serializer, auth and test naming.

## Workflow
1. Inspect the confirmed source of truth (acceptance criteria or OpenAPI), representative API tests, environment configuration and reusable request/response specifications.
2. Inventory method, path, path/query/header parameters, required and optional request fields, documented response codes/bodies/content types and security. Resolve references and flag unknown constraints.
3. Separate pure validation/parsing tests (JUnit unit) from single-call HTTP contract tests (integration) and multi-call journeys (E2E). Derive happy, negative, boundary, auth and response-schema cases only from documented behavior; avoid guessing 400/401/422/415.
4. Use JUnit 5 `@Test` or `@ParameterizedTest` with readable display names; fresh test data/builders per case. Keep REST Assured request/response specifications in existing shared setup; use per-request data and isolated cleanup rather than mutable global base URI or shared credentials.
5. Assert status, relevant headers and response data using existing matchers/JSON schema validator where installed. Avoid logging sensitive bodies, tokens or PII. Do not perform destructive calls against shared/prod environments without approval.
6. Run a targeted existing Gradle/Maven test selector; present passed/failed/unrun evidence separately from generated tests.

See [generation.md](generation.md) for contract-to-test procedure. If REST Assured or JUnit is absent, select a matching installed pack or produce manual inventory; do not generate Java code claiming it is executable.
