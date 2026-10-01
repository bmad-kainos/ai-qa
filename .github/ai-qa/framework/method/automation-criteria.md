# Automation decision

Determine whether existing tests already exercise each requirement and what new
assurance a proposed test would provide. Examine changed service boundaries, API
contracts/routing, backend branches, persistence/data integrity, caching, runtime flags,
authentication/authorisation, logs, environment variation and CI selection. Compare
execution stability and maintenance cost with the risk of leaving the behaviour manual.

Choose unit for isolated logic, integration for a request or component boundary, and
E2E for cross-system user journeys; a documented project convention may use different
names or tools. If automation is worthwhile, specify requirement IDs, test level and
smallest useful inventory, selected *observed* framework pack, file layout, real versus
mocked dependencies, safe data/cleanup, environment and CI impact. Otherwise justify a
manual-only or existing-coverage decision. Approval to recommend automation is not
approval to write or run tests.

For applicable REST API inputs include a successful case, absent required fields,
wrong field types, authentication rejection when auth is required, and at least two
boundaries per constrained field. Check valid endpoints/midpoints and an invalid
value against the *actual* schema, and assert status plus error payload shape. Mark
non-applicable cases and absent contracts rather than inventing constraints. Project
conventions supersede POC stack assumptions.
