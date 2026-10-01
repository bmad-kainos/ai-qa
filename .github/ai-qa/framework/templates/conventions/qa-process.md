# QA process conventions

> Generic source template. Only Configure, following an approved L5 adaptation,
> renders this to `.github/ai-qa/project/conventions/qa-process.md`.

<!-- ai-qa:managed:start -->
| Field | Project value | Confidence / source link and revision |
|---|---|---|
| Requirement source, ticket format and refinement owners | ∅ unknown | ∅ |
| Readiness thresholds and who approves design | ∅ unknown | ∅ |
| Scenario review and traceability expectations | ∅ unknown | ∅ |
| Manual versus automation ownership and risk priorities | ∅ unknown | ∅ |
| Test environments, access, side effects and cleanup | ∅ unknown | ∅ |
| Permitted safe targeted runs and gated long/full runs | ∅ unknown | ∅ |
| Failure triage, bug ownership and escalation | ∅ unknown | ∅ |
| Additional project-specific Do Not rules | ∅ unknown | ∅ |

Support `design`, `automate`, `full` and `triage` without forcing unrelated
steps for a focused request. Red readiness stops design finalisation until
refinement. Draft a plan before design approval; do not finalise it before that
decision. Orchestrated edits wait for workflow-plan approval, but L1 itself has
no standalone action gate. L0 reads; L2 branch/commit;
L3 risky or long runs; L4 external publication; L5 adaptation/dependencies/MCP.
These minimum gates cannot be weakened by project conventions.
<!-- ai-qa:managed:end -->

<!-- ai-qa:user -->
Project-authored QA process decisions; preserve verbatim on refresh.
<!-- /ai-qa:user -->
