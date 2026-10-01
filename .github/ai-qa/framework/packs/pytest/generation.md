# pytest generation workflow

1. Confirm pytest/config, representative tests, existing API client and fixtures. Discover expected behavior from acceptance criteria/OpenAPI; do not invent status or response structure.
2. Build a traceable inventory with level: pure logic without HTTP = unit, one exchange = integration, multi-step flow = E2E. Cover documented success, negative, constrained boundaries, schema, auth and content negotiation when applicable.
3. Follow existing test locations and fixture scopes; use fresh payloads, parameterized `ids`, registered markers and assertion messages identifying expected/actual/input. Client/auth/base URL come from approved existing configuration; no real network in unit tests.
4. Propose generated tests before writing; require authorization for data-changing tests and external actions. Use only installed clients and schema validators. Never add `pytest-playwright` assumptions without evidence.
5. Execute the smallest existing targeted selector if permitted. Label inventory, generated tests and executed evidence distinctly.

See [scenario inventory](examples/scenario-inventory.md) and [hypothetical Orders API snippets](examples/orders-api-example.md). Snippets are unrun illustrative source inside Markdown, not installed tests.
