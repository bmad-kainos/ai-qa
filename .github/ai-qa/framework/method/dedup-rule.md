# Manual scenario deduplication

Before creating a manual scenario, compare each `FR`/`NFR` and acceptance criterion with
**passing, relevant** unit/integration assertions. Merge already-proven internal rules
into broader business flows or omit them when they add no live-system assurance. A test
that merely exists, is skipped, or has no current run evidence does not qualify as passing.

Preserve manual validation of real API/service/database boundaries, business outcomes,
permissions, environment-dependent behaviour, changed runtime flags in both ON and OFF
states, over-mocked or untested branches, and HIGH/CRITICAL regression risks. Aim for the
smallest set of reproducible, deterministic BDD cases that covers those risks; do not
enforce one scenario per acceptance criterion or a fixed scenario count.

For every selected scenario specify its requirement IDs, setup/test data, observable
`GIVEN`/`WHEN`/`THEN`/`AND` outcome and cleanup. Add **Scenarios Not Written** listing each
omitted ID/category and the concrete existing passing test/coverage reason. If evidence
is absent, describe the uncertainty rather than claiming deliberate deduplication.
