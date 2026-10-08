# Requirement traceability

Extract and clearly structure each individual requirement with a stable ID: `FR1`, `FR2`, … for functional requirements and `NFR1`, `NFR2`, … for non-functional requirements. Reuse these exact IDs unchanged in every later step so coverage can be traced end to end. Append new IDs rather than silently renumbering existing ones. If a source changes, identify affected IDs and refresh dependent artefacts. Do not disguise an inference as an accepted requirement. For a ticket with no stated NFR, say “none specified” instead of inventing an `NFR`.

Functional requirements include core behaviours, business rules and validation logic. Non-functional requirements include performance expectations, security requirements, logging requirements and environment-specific behaviour. Also capture edge cases, feature flags, environmental dependencies, integration points (APIs, databases, external services), risk areas, ambiguities, missing information and potential implementation risks.

## Index matrix

`qa-work/<work-id>/index.md` is the durable traceability index. It contains one row for every `FR`/`NFR` and records: requirement ID → existing evidence → scenarios → automation decision → test files → last result. Keep the matrix current as work progresses, and distinguish **assessed**, **automated** and **deliberately not automated**. A recommended test is not a written test; a written test is not an executed test; a test result is not measured coverage or deployment validation.

| FR/NFR | Existing evidence (test/assertion or gap) | Scenarios | Automation decision (assessed / automated / deliberately not automated, with reason) | Test files | Last result (run / environment / time) |
|---|---|---|---|---|---|
| FR1 | Not assessed | — | Assessment pending | — | Not run |

For each requirement link its source and revision, acceptance criterion, observable outcome, implementation evidence, relevant test IDs/assertions and execution evidence. Record coverage gaps, current status and ambiguity. Distinguish a test file's existence, assertion relevance, actual execution result, measured coverage and deployment validation; none proves the others. Link test IDs, paths, report/CI run and environment when available.

## Requirement analysis output

1. **Structured requirements list** — functional, non-functional, edge cases and feature flags, with stable IDs.
2. **Implementation verification report** — whether implementation is present on the confirmed target branch, matches, deviates or has missing behaviour. If the branch is unavailable or implementation is not present, state this and proceed from the ticket description only.
3. **Risk areas** — ambiguities, missing acceptance criteria and potential issues.

## QA Summary

Use these exact columns in the index and ticket/sprint plan. State `Not assessed`, `Not run`, or `Not published` rather than implying evidence.

| Ticket | Readiness | Max risk | Coverage verdict | Scenarios written/not written | Automated/manual/not needed | Run result | Published |
|---|---|---|---|---|---|---|---|
| <ticket or work ID> | <Green / Amber / Red / Unknown> | <LOW / MEDIUM / HIGH / CRITICAL / Unknown> | <Pass / Needs Improvement / Insufficient / Not assessed> | <counts and linked IDs> | <decision and rationale> | <PASS / FAIL / BLOCKED / Not run, with evidence> | <destination and receipt / Not published> |

Never infer a passing result, requirement coverage or publication from a file's existence. A published status requires the provider receipt/link.
