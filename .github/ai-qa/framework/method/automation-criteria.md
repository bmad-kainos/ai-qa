# Automation decision

Evaluate whether automated integration or end-to-end tests should be added. Consider each factor and answer explicitly:

| Factor | Question |
|---|---|
| Cross-service impact | Does this change affect multiple services or components? |
| API changes | Are API routes, contracts, or gateway config affected? |
| Backend logic | Is core backend/processing logic changed? |
| Database side effects | Are database reads/writes affected? |
| Feature flags | Is behaviour gated behind a flag? |
| Caching behaviour | Could cached values cause stale or incorrect behaviour? |
| Authentication / authorisation | Are auth rules or permissions changed? |
| Logging validation | Should log output be validated as part of the change? |
| Environment-based config | Does behaviour differ across environments? |

Determine whether existing tests already exercise each requirement and what new assurance a proposed test would provide. Compare execution stability and maintenance cost with the risk of leaving the behaviour manual. State evidence for each factor; unknown evidence is not a negative finding.

## Coverage gaps to assess

Cross-reference the source and test inventories before recommending new automation. Identify the applicable gap types:

| Gap type | Description |
|---|---|
| **No tests** | Source file or module has no corresponding test file. |
| **Missing test level** | Integration tests exist but no unit tests, or vice versa. |
| **Untested function** | Public function/method has no test covering it. |
| **Untested error path** | Exception handling or error branches have no negative test. |
| **Untested boundary** | Numeric or enum field has no boundary/edge-case tests. |
| **Happy path only** | Tests exist but cover only the success case. |

Focus on production code, not test helpers, fixtures or `conftest.py`. Prioritise money/billing, authentication/security, persistence and public APIs. A missing test file is higher risk than a missing edge case in an otherwise well-tested module. If a coverage report is available, use it with the structural inventory; do not invent coverage percentages or present a missing file as proof of missing assertions.

## Test level decision tree

Use the project's observed test conventions and selected framework pack. The following levels are the default decision tree:

```text
Is it testing a pure function with no HTTP calls? → Unit
Is it testing one request/response cycle? → Integration
Does it involve auth flows, chained calls, or multi-system paths? → E2E
```

When in doubt, prefer integration over E2E for API tests. Project conventions may name levels differently. Choose unit for isolated logic, integration for a request or component boundary, and E2E for cross-system user journeys.

## If automation is justified

Propose the following:
- **Test scope** — what is being tested end-to-end
- **Test structure** — file and folder layout for new tests
- **Mocking strategy** — what is mocked vs real
- **Environment strategy** — which environment, test data approach
- **CI impact** — will new tests affect pipeline duration or stability?

Specify requirement IDs, level, the smallest useful inventory, the observed framework pack and conventions, real versus mocked dependencies, safe data and cleanup, environment, and CI impact. Do not invent a framework. For REST API tests, build an inventory before writing tests. At minimum cover happy path, missing required fields, invalid types, authentication failure when auth exists, and two boundary cases per constrained field. Check min, max, valid midpoint and invalid values against the actual schema. Assert status code and error response structure. Mark non-applicable cases and absent contracts rather than inventing constraints.

## Impact level

Classify the automation impact separately from risk:

| Level | Meaning |
|---|---|
| **None** | Existing coverage is sufficient. No new automation needed. |
| **Low** | Small additions to existing test files or fixtures. |
| **Medium** | New test scenarios required — new file or new test class. |
| **High** | Significant automation effort or framework work required (new fixture types, new helpers, new fixture patterns). |

Use `effort-estimation.md` for effort reasoning. State whether automation is justified and why, per scenario: automate at a level, manual, or not needed. Approval to recommend automation is not approval to write or run tests.

## If automation is not justified

State clearly why automation is not warranted and confirm that manual testing is sufficient, or explain which existing coverage already provides the required assurance. A manual-only decision is not a waiver of high/critical risk coverage.
