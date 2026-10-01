# QA automation effort

Default to an **impact class**, not a fabricated hour estimate:

| Class | Typical scope |
|---|---|
| None | Existing assertions cover the change; no additional automation proposed. |
| Low | Small addition using established tests or fixtures. |
| Medium | New scenarios or a dedicated test module with known dependencies. |
| High | New harness, environment orchestration or substantial reusable fixture work. |

Explain the size using observed requirements, test inventory and available infrastructure.
Existing reusable fixtures, clear criteria and an available environment can reduce
uncertainty; new service access, unstable environments, bespoke mocks, complex data
and dependencies increase it. A missing safe test environment or fundamentally
unrepeatable operation is a **blocker**, not just a larger estimate.

Provide hours only if the user expressly asks and the project has comparable,
locally evidenced work or a confirmed estimation convention. Then show assumptions,
breakdown by task, range and confidence; do not adopt example hour tables from
another project as a promise. Red readiness must be refined before treating an
estimate as actionable.
