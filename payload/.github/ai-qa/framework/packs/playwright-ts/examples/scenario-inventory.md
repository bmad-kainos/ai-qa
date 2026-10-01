# Playwright TypeScript — sample test inventory (not executed)

Assume a **hypothetical** contract documents `GET /widgets/{id}` returning 200 for an existing ID and 404 for a missing ID. Do not reuse its expectations for a real API without confirming that API's contract.

| Source | Level | Scenario | Input | Expected contract result | Status |
|---|---|---|---|---|---|
| Hypothetical contract `GET /widgets/{id}` | Integration | Existing widget | Known isolated ID | 200 and documented response fields | Proposed, unverified |
| Same | Integration | Missing widget | Confirmed absent ID | 404 and documented error shape | Proposed, unverified |
| Same | Integration | Unauthorized access | No credential | Unknown until security scheme/responses are documented | Blocked, needs contract |

Use Playwright's `request` fixture and existing config if implementation is authorized. No test or service was run for this example.
