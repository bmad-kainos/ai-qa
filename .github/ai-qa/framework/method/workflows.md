# QA workflows and handoffs

All `qa-*` skills are **independently invocable** when supplied sufficient context; none requires a previous skill as a hard prerequisite. Read `safety.md` and `discovery.md`, then project conventions and the relevant skill. **The project's confirmed conventions and this framework's safety gates override project-specific example commands, stack assumptions and file layouts in either reference POC.** For a resumable multi-step workflow use `qa-work/<work-id>/index.md` as the traceability index: scope, ticket/branch/revision, requirements IDs, evidence and provenance, readiness, risk, approvals, step statuses, output links and open questions. Do not commit credentials or raw test data. Recheck source freshness (ticket revision, branch/commit, config and code) before reusing an earlier artefact; rerun only stale or missing steps. Present decisions in chat and do not claim unfinished steps completed.

Use `precedence.md` for conflicting instructions, `git.md` for work-ID and
branch precedence, `readiness.md` for design entry,
`traceability.md` and `dedup-rule.md` for requirement coverage, `regression-areas.md`
for the mandatory matrix, `automation-criteria.md` and `effort-estimation.md` for
automation decisions, `failure-classes.md` for triage, `artefacts.md` for durable
outputs and `questions.md` for interaction gates.

## Design

1. `qa-analyse-requirement` extracts stable `FR`/`NFR` IDs and scores Feabhas QA readiness (Green/Amber/Red) and ownership. **Red stops** design for refinement; record blockers, do not invent ACs.
2. `qa-code-context` maps changed code and validates implementation on a confirmed branch where accessible.
3. `qa-coverage-gaps` inventories test evidence and maps assertions to requirements; separate existence, execution and measured coverage.
4. `qa-design-tests` proposes lean manual BDD and integration/E2E scenarios, including deliberate omissions.
5. `qa-regression-risk` completes the mandatory 13-area risk matrix and high-risk validation.
6. `qa-automation-plan` recommends appropriate levels, scope, framework, mocks, data and CI implications.
7. `qa-review-tests` reviews the design/available tests for gaps and false confidence.
8. Show the proposed design and draft plan in chat; obtain design approval **before finalising** and workflow-plan approval **before orchestrated L1 local edits**. L1 itself needs no additional action prompt on a non-default branch; summarise local changes afterwards. `qa-test-plan` then prepares a complete traceable plan and the eight-column QA Summary from `ticket-to-test-plan.md`; external publication is a separate L4 action through `qa-publish`.

For an explicit Jira ticket-to-test-plan request, also follow `ticket-to-test-plan.md` and its six Generic POC steps in order. Project/provider-specific skill outputs may enrich but must not erase that methodology. For a standalone feature, a pasted spec or an independent skill, do not invent a ticket ID.

## Automate

Start from an approved design or provided scenarios. Inspect project framework pack and existing test inventory before deciding the smallest useful change. For REST API test inventories, include at minimum a happy path, missing required fields, invalid types, auth failure **where auth exists**, and at least two boundary cases per constrained field; verify the observed contract's min/max, valid mid and invalid values, and assert both status and response structure for errors. Mark inapplicable cases explicitly rather than inventing fields/auth, and honour stricter project conventions. Use `qa-branch` with **L2** approval for branch creation (no automatic push), then `qa-generate-tests` to change only test-owned files on a non-default branch under **L1** (no extra action gate after orchestrated plan approval). Summarise local changes. Follow project naming, safe fixture/test data and observed runner conventions rather than assuming a stack. Run targeted static checks/tests through `qa-run-tests`; obtain **L3** approval for full, environment-dependent or shared-service runs. Record actual selectors, environment, commit, status and evidence. Use `qa-analyse-failure` to classify a failure; correct only test defects within the work item for at most three iterations, never change product code to green a QA run. Report unresolved product defects via a drafted `qa-bug-report`. Branch push, PR creation and bug publication each require separate **L4** approval.

## Full and triage

`full` runs design then automate only after design approval and each later action gate; Red readiness blocks automation until refined. `triage` starts from actual failure/log evidence, uses `qa-analyse-failure` to distinguish product regression, flaky test, obsolete expectation, data and environment issues, and may *draft* `qa-bug-report` with severity, reproduction, expected/actual, evidence, confidence and unknowns. Do not create a ticket or publish a report without L4.

For independent audits use `qa-discover`, `qa-regression-risk`, `qa-baseline`, `qa-analyse-docs`, `qa-tech-report`, `qa-retrospective`, `qa-run-tests` or another directly relevant skill without forcing these workflows. Missing integrations fall back to pasted work items/manual output; disclose unavailable data. Never infer a clean regression from an unrun or skipped suite.
