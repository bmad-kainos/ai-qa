# Wave 1 MVP: mapping AI-QA to the AI-Supported Testing Adoption plan

This maps the Wave 1 plan (Phase 1 Test Design, Phase 2 Test Code Creation) onto what AI-QA provides today. It also defines the MVP training scope. Nothing outside the MVP is removed; it stays available for teams that want it.

## 1. MVP deliverables

Entry points and skills for the daily QA loop of requirement → scenarios → automation decision → generated tests → review.

| Role | MVP item | Why it is MVP |
|---|---|---|
| Setup (once per repo) | `@qa-configure` | Captures the team's own conventions (stack, paths, scenario format, test data rules). This is the "adapt to existing standards, else sensible default" requirement. |
| Main agent | `@qa` with the `design` and `automate` workflows | One entry point, routing to the skills below. `full` is `design` then `automate`. |
| Phase 1 skills | `qa-analyse-requirement`, `qa-coverage-gaps`, `qa-design-scenarios`, `qa-automation-plan`, `qa-review-tests` (design mode) | Risks, existing coverage, scenarios, test-level decision, scenario quality gate. |
| Phase 2 skills | `qa-generate-tests`, `qa-review-tests` (code mode) | Convention-seeded test code and the code-review gate. |
| Seed material | Packs under `.github/ai-qa/framework/packs/` (`playwright-ts`, `pytest`, `jest-vitest`, `junit5-restassured`, `cypress-ts`, `selenium-java`, `cucumber-java`) and their `examples/` | The "stack-specific prompt variants and good examples" for Phase 2. |
| Supporting (invoked by the workflows, not taught separately) | `qa-map-code`, `qa-regression-risk`, `qa-test-plan` | Run inside `design`; they add depth but are not the core of the training. |

Present but outside the MVP (leave installed, do not teach in the first session):

- Wave 2 candidates: `qa-run-tests`, `qa-analyse-failure`, `qa-baseline`, `qa-retrospective`, `triage` workflow. These match the Wave 2 areas of maintenance and execution.
- Publishing and engineering: `qa-publish`, `qa-bug-report`, `qa-create-branch`, `qa-create-pr`, `qa-tech-report`, `qa-update-docs`, `qa-ask-docs`, `qa-discover`.
- Optional Atlassian scripts and MCP.

Suggested training shape: a short `@qa-configure` demo, then one live `@qa design <ticket>` run, then one `@qa automate` run on the approved design, then a review of the gates. Show the individual skills only as "you can call these directly".

## 2. Phase 1 (Test Design) mapping

| Wave 1 capability | AI-QA coverage | Skill / file | Status |
|---|---|---|---|
| Analyse requirements, identify risks and dependencies | Readiness assessment, stable FR/NFR IDs, refinement questions, risk | `qa-analyse-requirement`, `method/readiness.md`, `qa-regression-risk` | Covered |
| Generate scenarios incl. edge and negative cases | Lean, traceable scenarios (Given/When/Then or steps); boundary and negative cases required | `qa-design-scenarios`, `method/scenario-format.md` | Covered |
| Preconditions and test data needs | Scenarios must state environment, setup, test data, and cleanup | `method/scenario-format.md`, `conventions/testing.md` (Test data rules) | Covered |
| Classify each scenario to unit / integration / UI-E2E, flag UI-by-default | Per-scenario automate / manual / not-needed decision with test level, location, mocking, environment and justification | `qa-automation-plan`, `method/automation-criteria.md` | Covered. A requested level that differs from the recommended one is challenged: the plan shows both levels per scenario and asks the user to confirm ([PR #25](https://github.com/bmad-kainos/ai-qa/pull/25)). |
| Estimate relative complexity of testing effort | Effort reference exists, in hours per level, not Fibonacci | `method/effort-estimation.md` | Partial. Needs a Fibonacci complexity output (see section 5). |
| Check existing coverage before adding scenarios | Requirement-to-test evidence at unit/integration/E2E; inventory mode | `qa-coverage-gaps` | Covered |
| Avoid duplicating cheaper-level coverage | Dedup rule applied at design and review | `method/dedup-rule.md`, `qa-review-tests` design mode | Covered |

### Phase 1 quality gate against `qa-review-tests` (design mode)

| Gate criterion | Where AI-QA checks it |
|---|---|
| Each scenario traces to a requirement/AC | Review step 1: each scenario must name `Covers: FRn/NFRn`; uncovered requirements must be listed under Scenarios Not Written. |
| Happy path, boundary and negative represented | Review step 3: boundary/negative paths and meaningful categories. |
| Level assigned with justification; UI flagged | `qa-automation-plan` output, checked in design review. A requested level that differs from the recommended one (e.g. E2E asked for, integration or unit recommended) is shown with its trade-off and needs user confirmation ([PR #25](https://github.com/bmad-kainos/ai-qa/pull/25)). |
| Preconditions, dependencies, test data documented and feasible | Review step 3: deterministic data, environment clarity, cleanup. |
| No duplication of cheaper-level coverage | Review step 2 against `dedup-rule.md`. |
| Existing coverage checked first | `qa-coverage-gaps` runs before `qa-design-scenarios` in the `design` workflow. |
| Complexity estimate present and reasonable | Not checked today. Gap (section 5). |

## 3. Phase 2 (Test Code Creation) mapping

| Wave 1 capability | AI-QA coverage | Skill / file | Status |
|---|---|---|---|
| Generate unit/integration/UI test code from an approved scenario | `automate` workflow generates tests from the approved plan, endpoint, or OpenAPI | `qa-generate-tests` | Covered. Generation stops for any scenario whose requested level differs from the recommended one until the user confirms, on every input path (plan, OpenAPI, endpoint description, scenarios) ([PR #25](https://github.com/bmad-kainos/ai-qa/pull/25)). |
| Seeded with team conventions (e.g. page-object rules) | `@qa-configure` renders project conventions and pack instructions, scoped via `applyTo` to the discovered test paths. Precedence is user > project conventions > neighbouring code > pack > defaults. | `.github/instructions/qa-*.instructions.md`, `conventions/testing.md`, `precedence.md` | Covered |
| 2-3 stack-specific prompt variants plus a generic unit variant | 7 packs with `generation.md` (playwright-ts, pytest, junit5-restassured) and `instructions.template.md`; `_TEMPLATE` for new stacks | `framework/packs/` | Covered. `generation.md` exists for 3 of the 7 packs only. |
| Short library of good examples | Worked examples per pack (unit, integration, e2e, fixtures, config) | `packs/*/examples/` | Covered for playwright-ts, pytest, junit5-restassured. |
| Fall back to a sensible default when no standards are given | Framework defaults, with `★` defaults and unknowns flagged | `framework/defaults/` | Covered |

### Phase 2 code-review gate against `qa-review-tests` (code mode)

| Gate criterion | Where AI-QA checks it |
|---|---|
| Follows conventions | Compares code to `conventions/testing.md` and the pack's `pack.md` (paths, naming, fixtures, tags, assertions). |
| Good practice: parallel-safe, isolated data, no flaky patterns | Pack anti-patterns (e.g. no `waitForTimeout`, `time.sleep`, `cy.wait(n)`, shared mutable state, order dependence); checks isolation, determinism, retries and timing. |
| Correct coverage, no drift from approved design | Requirement-to-assertion traceability; checks assertions, not names. |
| No duplication | Applies the dedup rule and "do not duplicate existing assertions" in generation. |
| Safe by default (no secrets or production data) | Secrets in tests rate Critical; safety rules say env-var names only. |

Code-mode review output reports all five headings above as an explicit PASS or FAIL with evidence, and tags each finding with the headings it affects ([PR #26](https://github.com/bmad-kainos/ai-qa/pull/26)). Severity ranking and the findings table are unchanged, insufficient evidence counts as FAIL, and any FAIL prevents an overall **Pass** verdict.

## 4. Cross-cutting requirements

| Plan requirement | AI-QA coverage |
|---|---|
| Stack-agnostic, adaptable to project standards | Discovery then confirm then adapt via `@qa-configure`; packs are optional and project conventions win. |
| No infrastructure or procurement; rides on Copilot | Markdown agents and skills only; no runtime or binaries. |
| Human always in the loop, per phase | Explicit approval points: red readiness stops the workflow, design approval before the plan is final, and L2/L3/L4/L5 safety gates before writes, runs, publishing or installs. The independent `qa-review-tests` pass runs after each phase. |
| Repeatable and reviewable | Work records in `qa-work/<work-id>/` with `index.md`, numbered artefacts, stable IDs and traceability matrix. |
| Time saved is the value metric | Not measured by AI-QA today (section 5). |

## 5. Gaps against the plan

| # | Gap | Impact | Suggested action | Status / decision |
|---|---|---|---|---|
| 1 | Complexity estimate is hours-based, not Fibonacci, and no gate checks it | Phase 1 criterion not met | Add a Fibonacci complexity line per ticket to the `qa-automation-plan` / `qa-test-plan` output and a check in design review. | Deprioritised, not in MVP. AI-generated estimates are contentious because human-only and AI-assisted effort differ. Revisit later, possibly via `qa-configure`. |
| 2 | No named human reviewer role or pass/fail criteria for each gate | The plan's guardrail ("a named role, not just 'a human reviewed it'") is only partly met; the reviewer is the user | Add a "Reviewer role and pass criteria" section to `conventions/qa-process.md` (configure-owned) and name the role per phase, e.g. QA Lead for design, Senior SDET for code. | Under discussion, not in MVP. Open points: who approves each gate, where sign-off is recorded (e.g. `index.md` gate log), whether the framework enforces it. Simple default for training: the QA who ran the workflow signs off using the review output. |
| 3 | "UI flagged where a cheaper level would do" may not be an explicit output field | Weak signal on the plan's key risk | Add a column or flag to the `qa-automation-plan` output. | Implemented ([#23](https://github.com/bmad-kainos/ai-qa/issues/23), [PR #25](https://github.com/bmad-kainos/ai-qa/pull/25)): the framework challenges the user when the requested level differs from the recommended one, in either direction. Follow-up idea, not yet filed and post-MVP: a read-only skill that scans existing tests and proposes lower levels (file, test, current level, proposed level, justification, confidence), building on `qa-coverage-gaps --inventory`. |
| 4 | No tracking of AI-adoption ratio (target at least 75%) | Cannot report the checkpoint criterion | Out of scope for the framework. Capture it via the work records (count `qa-work/*` with generated artefacts) or team self-report. | Out of scope; cannot be reported by the framework. |
| 5 | Baseline metrics (design time, shift-left %, automation lead time, defect leakage, cost) are not captured | The 3-month comparison needs them. `qa-baseline` covers test inventory, CI pass rate and flakiness only | Use `qa-baseline snapshot` for the CI pass rate floor. Capture the other metrics through a team self-report template; this is separate from the framework. | Leave for now, not in MVP. |
| 6 | `generation.md` and examples exist for only 3 of the 7 packs | Phase 2 seed library is uneven | In the first rollout, pick projects on playwright-ts, pytest or junit5-restassured. Add the others as needed using `packs/_TEMPLATE`. | Leave for now. Handle through pilot project selection. |
| 7 | Quality-gate wording differs from the plan's wording | Teams may not recognise the gate | Optionally align review-tests headings with the plan's checklist (conventions, good practice, correct coverage, no duplication, safe by default). | Implemented ([#24](https://github.com/bmad-kainos/ai-qa/issues/24), [PR #26](https://github.com/bmad-kainos/ai-qa/pull/26)). Training note: the plan's five headings now appear in the review output. |

## 6. Suggested first-sprint adoption per team

1. Install, then `@qa-configure`. Review the project layer diff; confirm the stack, scenario format, test paths and test data rules.
2. Run `@qa design` on 2-3 real tickets. Record time taken against the team's baseline.
3. Run `@qa automate` on one approved design with a supported pack. Review the generated tests with the code-mode review.
4. Adjust `conventions/testing.md` through `@qa-configure refresh` where the output missed the team's standards.
5. Take `qa-baseline snapshot` early so the month-3 comparison has a CI "before".

## 7. What has been implemented for this plan

Two gaps from section 5 are now closed in the framework. Each change has regression tests in `tests/`.

| Plan item (section) | Gap | Issue / PR | What it does |
|---|---|---|---|
| Phase 1: classify each scenario to a test level and flag UI-by-default (section 2) | 3 | [#23](https://github.com/bmad-kainos/ai-qa/issues/23) / [PR #25](https://github.com/bmad-kainos/ai-qa/pull/25), branch `fix/challenge-mismatched-test-levels-23` | `qa-automation-plan`, `qa-generate-tests` and `method/automation-criteria.md` ask the user to confirm when the requested level differs from the recommended one, in both directions and for every pair of levels. The scenario is `Automate (blocked)` until confirmed, and the confirmation applies only to that scenario. The plan table keeps the decision separate from the Requested level, Recommended level and Final level / status columns (`N/A` for Manual and Not needed scenarios), and the same columns appear in the `qa-generate-tests` inventories. The gate covers every generation input, not just a plan. |
| Phase 2: code-review quality gate (section 3) | 7 | [#24](https://github.com/bmad-kainos/ai-qa/issues/24) / [PR #26](https://github.com/bmad-kainos/ai-qa/pull/26), branch `fix/review-tests-quality-headings-24` | `qa-review-tests` code mode reports PASS or FAIL for conventions, good practice, correct coverage, no duplication and safe by default, tags findings with those headings, and keeps severity ranking. Insufficient evidence is FAIL. Any FAIL prevents a **Pass** verdict (**Insufficient** if only evidence is missing, otherwise **Needs Improvement**). |

Still open:

| Item | Status |
|---|---|
| Gap 2: named human reviewer role and recorded sign-off | Under discussion. |
| Gap 1: Fibonacci or other complexity estimate | Deprioritised. |
| Gaps 4, 5, 6: adoption ratio, baseline metrics, pack coverage | Out of scope or leave for now (section 5). |
| Level-review skill (scan existing tests for lower levels) | Idea only, not filed. |
| Default `qa-work/` commit policy in installed repos | Raised as a discussion point; no change made. |
