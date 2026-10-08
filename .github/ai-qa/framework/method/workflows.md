# QA workflows

All `qa-*` skills are independently invocable with sufficient context. Workflows are resumable and skippable: inspect `qa-work/<work-id>/index.md`, confirm scope and inputs, reuse only non-stale artefacts, and run only missing or stale steps. Never claim unfinished work complete. Keep decisions, step state, evidence, links and gate results in the index. The user may skip a step; record the omission and its consequence. A skill does not require an earlier skill as a hard prerequisite: gather the minimum missing context yourself.

Read `safety.md`, `precedence.md`, relevant project conventions and the method files for the current work. Confirm the work ID per `work-id-and-git.md`. Project conventions control project specifics; safety gates remain authoritative. Do not commit credentials or raw test data.

## design

1. `qa-analyse-requirement`: fetch or use provided ticket context; assign stable `FR`/`NFR` IDs; identify edge cases, flags, integration points, ambiguities and missing information; assess six readiness scores, RAG, QA ownership/recommendation, observability and prerequisites.
2. **Red readiness stops design.** Record blockers and offer refinement questions; do not invent acceptance criteria or continue to automation.
3. `qa-map-code`: identify the minimal affected files and flows, dependencies, side effects, related tests and docs. If a branch is given, verify each requirement as present / matches / deviates / missing and record flags/environment logic.
4. `qa-coverage-gaps(requirement)`: assess per-FR evidence at unit/integration/E2E levels, the coverage verdict and role boundary. Distinguish existence, assertion relevance, execution and measured coverage.
5. `qa-design-scenarios`: create lean manual scenarios in the configured Scenario format (`scenario-format.md`) using the dedup rule; state `Covers: FRn`, selective categories, quality criteria and **Scenarios Not Written**.
6. `qa-regression-risk`: complete all 13 areas, escalation rules and HIGH/CRITICAL handling.
7. `qa-automation-plan`: decide per scenario automated (level/location/mocking/environment/CI impact), manual or not needed; justify against the nine factors and impact level.
8. `qa-review-tests(design)`: check FR/NFR traceability, redundancy, determinism and risk gaps.
9. Show design and draft test plan; obtain **design approval before finalising**. Then `qa-test-plan` produces ticket-scope sections and QA Summary. External publication is a separate L4 action via `qa-publish`.

At the end of design, print the TL;DR and numbered Next Steps from `index.md`/the test plan, then show the QA Summary in chat using the exact columns: Ticket · Readiness · Max risk · Coverage verdict · Scenarios written/not written · Automated/manual/not needed · Run result · Published.

## automate

Start from approved design or supplied scenarios. Inspect the selected pack and test inventory; choose the smallest useful change. Generate the scenario inventory first. For REST inputs include happy path, missing required fields, invalid types, auth failure when auth exists and at least two boundary cases per constrained field; check the actual schema and mark inapplicable cases rather than inventing constraints.

1. `qa-create-branch` may propose a branch; local branch creation is separately gated at L2. Branch creation never authorises push.
2. `qa-generate-tests` creates only test-owned files under L1, on a non-default branch, after workflow-plan approval. Dependency installation is L5.
3. `qa-review-tests(code)` checks generated/existing tests against FR/NFR, project conventions and pack anti-patterns.
4. `qa-run-tests` runs the appropriate path/tag/risk subset or configured static checks. Full, environment-dependent, long or shared-service runs require L3 unless expressly safe in `qa-process.md`.
5. `qa-analyse-failure` classifies each result and applies the bounded fix loop: test defects only, only files created/modified in this work item, maximum 3 iterations, stop early on repeat, append every attempt to `09_execution.md`.
6. Update index and test plan with actual command, selector, environment, commit, results and evidence. Report local edits.

Push, PR creation, external comments, bug creation and publication each require their own L4 gate. Never change product code to make QA tests pass.

## full

`full` runs **design → checkpoint → automate**. Red readiness stops before checkpoint. At the checkpoint show the design/plan and ask for explicit design approval; proceed only after approval. Automate then follows its step gates. At completion update the index/test plan and show QA Summary in chat. Offer, but do not perform without separate L4 approval, `qa-publish` or `qa-create-pr`.

## triage

Start from a test run, pasted log or CI run reference; missing optional provider support falls back to pasted evidence. `qa-analyse-failure` classifies each failure with evidence and confidence, uses non-causal wording and the bounded fix loop. For evidence-backed application defects, offer a `qa-bug-report` draft. Creating a work item or publishing is L4 and requires exact-content/destination approval.

## Gates and independent skills

Gates are per step: workflow-plan approval before orchestrated L1 edits; design approval before finalising the plan; L2 branch/commit; L3 unsafe/full/environment-dependent runs; L4 each external write/push/PR; L5 install/adaptation-layer/mcp configuration. Record approvals and outcomes in the index. L1 itself has no separate action prompt and all local changes are summarised.

Independent skills remain available without forcing a workflow, including `qa-discover`, `qa-regression-risk`, `qa-baseline`, `qa-ask-docs`, `qa-tech-report`, `qa-retrospective`, `qa-run-tests`, and any other directly relevant skill. Never infer a clean regression from an unrun or skipped suite.
