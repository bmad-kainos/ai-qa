# Requirement traceability

Identify every independently testable functional rule as `FR1`, `FR2`, … and non-functional
expectation as `NFR1`, `NFR2`, … . Record each ID's source document/ticket revision,
acceptance criterion, observable outcome, and any ambiguity. Keep IDs stable across
analysis, code verification, unit coverage, BDD scenarios, automation and the final plan;
append new IDs rather than silently renumbering existing ones. Do not disguise an
inference as an accepted requirement.

| ID | Source / revision | Expected outcome | Implementation evidence | Test assertions / run evidence | Status / gap |
|---|---|---|---|---|---|
| FR1 | ∅ | ∅ | Not verified | Not assessed | Unknown |
| NFR1 | ∅ | ∅ | Not verified | Not assessed | Unknown |

Distinguish a test file's **existence**, assertion relevance, actual execution result,
measured coverage and deployment validation; none proves the others. Link test IDs,
paths, report/CI run and environment when available. If a source changes, identify which
IDs are affected and refresh those dependent artefacts. For a ticket with no stated NFR,
say “none specified” instead of inventing `NFR1`; sample rows above are schema examples.
