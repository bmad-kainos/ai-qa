# Playwright TypeScript generation workflow

1. Confirm `@playwright/test`, representative specs, test roots, `baseURL`, auth setup and approved environment. Read authoritative requirements or OpenAPI spec, not implementation assumptions.
2. Present an inventory: `source | level | concern/method/path | scenario | input/state | expected observable result | confidence`. Distinguish contract-backed expected HTTP statuses from questions.
3. For UI cover positive, failure, permission and meaningful edge flows with user-visible assertions. For APIs cover contract-listed success and error statuses, required/optional payloads, type/null/enum and each documented boundary, response schema/content type and security. Parameterize repeated cases.
4. Generate only if authorized: match existing imports and fixtures, use `request` for HTTP and `page` for browser flows; fresh payload factories, isolated data/cleanup and no embedded credentials. Do not invent schema validator dependencies.
5. Run the existing targeted test command if permitted. Report generated versus run/passed/failed cases and trace back to inventory. Flag unresolved contract refs, environment and auth instead of claiming verification.

See [scenario inventory](examples/scenario-inventory.md) and [hypothetical Orders API snippets](examples/orders-api-example.md). Snippets are unrun illustrative source inside Markdown, not installed test files.
