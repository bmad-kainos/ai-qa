# JUnit 5 + REST Assured API test generation

Select this guidance only when project manifests and representative tests confirm JUnit Jupiter and REST Assured. Follow the project's Java/Kotlin package, naming, runner, request/response specifications, fixtures, serializers, auth and environment configuration.

1. Verify existing dependencies, runner version, representative tests, package layout, configured environment/auth and reusable specifications/builders. Do not add dependencies or assume an endpoint environment.
2. Read the authoritative OpenAPI/acceptance criteria. Inventory method/path, path/query/header parameters, required/optional request fields, documented response codes/bodies/content types and security. Resolve references or mark unknown constraints.
3. Separate pure validation/parsing tests (unit), single-call HTTP contract tests (integration), and multi-call journeys (E2E). Derive happy, contract, negative, boundary, security and header cases only from documented behavior; never guess 400/401/422/415.
4. Present the complete scenario inventory before writing tests. Trace each case to its source, expected result, category and intended file.
5. Use JUnit 5 `@Test` or `@ParameterizedTest` with readable display names and fresh data/builders per case. Keep REST Assured request/response specifications in established shared setup; avoid mutable global base URI or shared credentials.
6. Assert documented status, relevant headers and response data using existing matchers or an already-installed JSON Schema validator. Avoid logging sensitive bodies, tokens or PII. Do not perform destructive calls against shared/production environments without approval.
7. Run only a documented targeted Maven/Gradle lint/compile command for generation validation; execution follows `qa-run-tests` and L3 gates. Report generated, compiled, executed and passed separately.

The real source examples are in [OrdersContractTest.java](examples/src/test/java/example/orders/OrdersContractTest.java), [OrdersBoundariesTest.java](examples/src/test/java/example/orders/OrdersBoundariesTest.java), and [OrderPayloads.java](examples/src/test/java/example/orders/OrderPayloads.java). They are illustrative and have not been run against an API; adapt their hypothetical contract only after verification.
