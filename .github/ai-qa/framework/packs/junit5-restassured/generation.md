# JUnit 5 + REST Assured generation workflow

1. Verify both dependencies, runner version, representative tests, Java package, environment/auth config and existing specifications/builders. Select a safe test environment and authorized read/write scope.
2. Read authoritative OpenAPI/acceptance criteria. Inventory operation/method/path, parameters, content type, security and each documented response; resolve references or flag them unknown. Map cases to unit, integration or E2E.
3. Cover minimal/full valid requests, documented negative statuses and error shapes, required-field/type/null/enum cases, just-inside/at/outside documented boundaries, auth failures and response schema/headers only where specified. Keep each case traceable; don't invent a generic 400/422 rule.
4. Generate JUnit Jupiter tests with existing naming and parameterization; use REST Assured existing shared request/response specifications without mutable static per-test auth/base URI. Fresh data, independent teardown, no secrets/logging of private payloads.
5. Run an existing targeted Maven/Gradle selector if approved. Report unrun tests and missing fixtures/schema-validation dependencies as gaps, not successful validation.

See [scenario inventory](examples/scenario-inventory.md) and [hypothetical Orders API JUnit 5 / REST Assured snippet](examples/orders-api-example.md). The Java snippet is illustrative Markdown, not an installed source file.
