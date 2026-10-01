# QA work index — template

Use as a field guide for a **project-owned** `qa-work/<work-id>/index.md`
on a non-default branch. Orchestrated edits follow workflow-plan approval;
standalone local output needs no extra L1 prompt. See `method/artefacts.md`
for required per-file YAML frontmatter (`work-id`, `skill`,
`framework-version`, `created`, `inputs`), staleness rule (any input newer),
work layout and default commit policy. The work ID may be a ticket, feature
or investigation, never a fabricated issue key.

| Field | Value |
|---|---|
| Scope / work ID | unknown |
| Requirement source and revision | unknown |
| Repository / confirmed branch / commit | unknown |
| Workflow and requested outputs | unknown |
| Discovery evidence (`discovery.md`) | unknown / not produced |
| Readiness / owners / blockers | unknown |
| QA Summary (Ticket / Readiness / Max risk / Coverage verdict / Scenarios written-not written / Automated-manual-not needed / Run result / Published) | unknown |
| FR/NFR IDs and links to evidence | unknown |
| Risk level / regression matrix | unknown |
| Unit-test coverage verdict / evidence | Not assessed |
| Manual test result / evidence | Not yet executed |
| Automation decision / tests / CI evidence | unknown |
| Step status / artefact links | unknown |
| Action gates approved (scope, actor, time) | none |
| Open questions / freshness check | unknown |

## Requirement traceability

| FR/NFR | Existing evidence | Scenarios | Decision (assessed / automated / deliberately not automated, why) | Test files | Last result (run/env/time) |
|---|---|---|---|---|---|
| FR1 | Not assessed | — | Pending | — | Not run |

## Action gate log

| Gate | Action / target | Exact payload or command / side effects | Approver and time | Outcome / ID or URL |
|---|---|---|---|---|
| L2–L5 / workflow-plan / final-design as applicable | — | — | — | — |

Do not silently overwrite prior decisions or mark a step complete because a file exists. When resuming, compare source revision, branch, configuration and test run provenance, then reuse only non-stale artefacts. QA reads project configuration and may write authorised `qa-work` artefacts; only Configure writes `.github/ai-qa/project/`.
