# Execution and failure analysis

## Failure classes

Classify each observed failure using evidence; do not claim causality from correlation. Give the evidence and a confidence level for each classification. Use non-causal wording such as “the failure is consistent with…” and “the available evidence does not establish…”.

| Class | Evidence to seek |
|---|---|
| **Test defect** | Assertion, selector, fixture, setup, test assumptions or test implementation does not reflect the supported requirement or project convention. Include stale expectations and non-determinism only when supported by evidence. |
| **Application defect** | A reproducible mismatch between observed application behaviour and an accepted FR/NFR or contract. Cite the requirement and observed behaviour; do not infer a product defect from one failed assertion alone. |
| **Environment / infrastructure** | Environment availability/configuration, runner, network, permissions, external dependency or infrastructure evidence that can explain the result independently of application behaviour. |
| **Test data** | Missing, invalid, contaminated, stale or incorrectly provisioned test data; evidence of ownership, setup and cleanup where available. |
| **Unknown** | Evidence is absent, incomplete or conflicting. State what evidence or check would distinguish the plausible classes. |

Capture the failing test ID, exact assertion/error, expected and observed behaviour, relevant FR/NFR, commit, environment, run time, command/selector and log/report paths. Separate facts, inference, confidence and next discriminating check. A single HTTP/CI error does not establish an application defect. A rerun, if safe and approved where required, does not erase the original failure; append the new evidence.

## Fix loop

- Fix **test defects only**.
- Change only files created or modified in this work item; never product code.
- Never delete, skip or disable tests.
- Never loosen assertions unless the relevant FR supports it.
- Maximum 3 iterations; stop early if the same failure repeats.
- Append each iteration to `qa-work/<work-id>/execution.md`.

Each iteration records the evidence-backed test change, exact targeted rerun, result and confidence. Stop before another change if the failure repeats, the evidence is uncertain, or a required environment/dependency is blocked. Application defects are not fixed by this loop; offer to prepare a `qa-bug-report` draft. Do not publish it without the separate L4 gate.
