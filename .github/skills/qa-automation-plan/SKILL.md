---
name: qa-automation-plan
description: Evaluate the value of automated coverage and produce per-scenario decisions with test level, location, mocking, environment, CI impact and evidence-based justification.
argument-hint: "[ticket, feature, requirements or scenarios; optional work-id]"
---

# Automation Plan

Evaluate whether automated tests should be added and, for each scenario, recommend automation at a suitable level and location, manual validation, or no additional test. Base decisions on project conventions and the nine evaluation factors, not on a desire to maximise test count.

## When to use

Use to plan automation for a ticket, feature or set of scenarios, or to assess whether manual validation is sufficient. Can be used independently with requirements or code evidence. Does not write tests, install a framework or execute a suite.

## Reads

Always read `.github/ai-qa/project/project.md`, especially Environments, CI/CD, Components, Constraints and Data stores/external dependencies. Read `.github/ai-qa/project/conventions/testing.md` (Scopes, Commands, Reports, Environments and base URLs, Test data rules), `conventions/qa-process.md` (Definition of done and QA evidence, Commands safe to run, Team options), and `conventions/integrations.md` only for external system dependencies. Read `.github/ai-qa/framework/method/automation-criteria.md`, `traceability.md`, `precedence.md`, `safety.md` and `artefacts.md`; read the observed test pack's `pack.md` when relevant. Optional prior artefacts: `01_requirement_analysis.md`, `02_code_context.md`, `03_coverage_assessment.md`, `04_test_scenarios.md`, `05_regression_risk.md`, `index.md`.

If project context is missing, inspect existing tests and CI configuration, label inferences and suggest `qa-configure`; do not assume a framework or environment.

## Work-id

Resolve per `.github/ai-qa/framework/method/work-id-and-git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs

Accept a ticket, feature/change, requirements, candidate scenarios or automation request. Use existing FR/NFR IDs or derive stable provisional IDs. If a ticket key is supplied and configured access is available, fetch with `workitem.get`; provider/transport come from `conventions/integrations.md`, with pasted text as manual fallback (if retrieval fails, retry once, then ask for the pasted title, description and acceptance criteria per `clarifying-questions.md`). Use an existing test inventory, CI setup, coverage and regression analysis if available. If an environment or credential is unknown, plan around the blocker rather than inventing access.

If prior artefacts are missing, gather the minimum yourself; never refuse. Distinguish recommendation from implemented tests and passing results.

## Procedure

### Evaluation factors

For the change, answer each factor explicitly as Yes / No / Unknown with a short reason:

| Factor | Question |
|---|---|
| Cross-service impact | Does this change affect multiple services or components? |
| API changes | Are API routes, contracts or gateway configuration affected? |
| Backend logic | Is core backend/processing logic changed? |
| Database side effects | Are database reads or writes affected? |
| Feature flags | Is behavior gated behind a flag? |
| Caching behaviour | Could cached values cause stale or incorrect behavior? |
| Authentication / authorisation | Are authentication rules or permissions changed? |
| Logging validation | Should log output be validated as part of the change? |
| Environment-based configuration | Does behavior differ across environments? |

Consider available coverage, regression risk, cost, stability, maintenance burden and outcomes manual checks cannot protect. Existing adequate coverage is a valid reason not to add automation.

### Select a level

Use the configured test framework and project paths. Apply this decision tree per scenario:

```text
Pure function with no HTTP calls?              -> Unit
One request/response cycle?                    -> Integration
Auth flow, chained calls or multi-system path?  -> E2E
When in doubt for API tests, prefer integration over E2E.
```

`conventions/testing.md` → Scopes is authoritative for available levels, pack, paths and locations. Match existing file naming, fixtures/builders and markers; do not create a new framework when one exists.

### Requested level mismatches

For each scenario, determine the recommended level from the decision tree before considering a user-requested level. If an explicit requested level differs from the recommendation, show both levels, the evidence-based reason for the recommendation and the trade-off of using the requested level, then ask the user whether to use the requested or recommended level. Apply this rule in either direction and for every pair of levels. Until the user answers, mark the scenario **Automate (blocked)** with confirmation pending; do not present a final automation level or let downstream test generation proceed for it. Record the confirmed level, user's choice and rationale. A confirmation applies only to the named scenario. If no level was requested, report **Not specified** and use the recommendation without asking.

### Decide each scenario

For every requirement/scenario choose exactly one: **Automate**, **Automate (blocked)**, **Manual**, or **Not needed**. Use `Automate (blocked)` when automation is desirable but a named dependency or decision prevents it; downstream skills must not generate tests for it until unblocked. For `Automate`, specify:

- Level: unit, integration or E2E, justified by boundary and outcome.
- Location: concrete configured scope/path and likely test file naming pattern.
- Scope/assertions: behavior and outcome; for API tests inventory happy path, omitted required fields, invalid types/nulls, relevant auth failures, response schema/content negotiation when specified, and at least two boundary cases per constrained field. Match status and error-body assertions to a documented contract; never invent responses.
- Mocking: what is real versus mocked. Mock external dependencies where appropriate, not the behavior or contract under test; explain how over-mocking is avoided.
- Environment/data: configured environment, test-data convention and lifecycle, safe ticket-linked identifiers, secrets through approved configuration only, isolation and cleanup.
- CI impact: configured command/marker, trigger, runtime, flake/stability risk, dependencies and ownership. These are a plan, not authorization to run CI or install dependencies.

For `Manual`, state the exact observable check and environment/access required. For `Not needed`, explain existing evidence or why no additional coverage adds value. If automation is blocked, use `Automate (blocked)` and say what dependency or decision would unblock it.

### Classify automation impact

Do not estimate hours here (the hour bands in `effort-estimation.md` are used only by `qa-test-plan` for sprint scope). Give an impact level for the work: **None** (existing coverage sufficient), **Low** (small additions to existing test files/fixtures), **Medium** (new scenarios requiring a file/class), **High** (significant effort or framework work such as new fixture types/helpers/conftest patterns). Explain the classification. This impact level does not replace each scenario's Automate / Automate (blocked) / Manual / Not needed decision.

## Output

Write `qa-work/<work-id>/06_automation_plan.md` with front matter `work-id`, `skill: qa-automation-plan`, `framework-version`, `created` (UTC ISO date/time) and `inputs` (requirements, source revision, test/CI evidence). Include all nine factor answers, an overall impact level and this table. The Decision column always holds one of the four decisions; for a mismatch, set it to Automate (blocked) and show Final level / status as Confirmation pending until the user responds, then record the confirmed level and keep Decision as Automate:

Open the artefact with **Result** (one-sentence verdict) and **Do next** (max 3 ordered actions) lines per `.github/ai-qa/framework/templates/artefact.md`. If the numbered file is absent, read legacy `automation.md` as a fallback; always write the new name and never silently rename.

| Scenario / requirement | Decision | Requested level | Recommended level | Final level / status | Location | Mocking | Environment / data | CI impact | Justification / evidence |
|---|---|---|---|---|---|---|---|---|---|
| <scenario> | <Automate / Automate (blocked) / Manual / Not needed> | <level / Not specified> | <level> | <confirmed level / Confirmation pending> | <configured path> | <real vs mocked> | <environment, data, cleanup> | <command, trigger, runtime, stability> | <recommendation evidence and mismatch trade-off> |

Add a short example in the configured Scenario format only when it clarifies planned behavior; label it proposed. State blockers, manual alternatives, residual risk and whether existing coverage suffices. Update `qa-work/<work-id>/index.md` with decisions, FR/NFR links, evidence, environment/CI blockers, impact and artefact link. Summarise the decision and highest-impact scenarios in chat.

## Side effects and safety

| Action | Level | Gate |
|---|---|---|
| Read project code, tests, CI and configuration | L0 | None |
| Write `06_automation_plan.md` and update `index.md` on a non-default branch (default branch: `method/safety.md` fallback) | L1 | No gate; summarise changes |
| Generate/edit tests, install dependencies, run shared/environment tests | L1/L3/L5 | Outside this skill; workflow approval, L3 run gate, L5 installation gate apply |
| Publish, comment, push or create work items | L4 | Not performed; `qa-publish` only |
| Edit project context/conventions | L5 | Never performed; `qa-configure` only |

Do not include secret values, claim tests are implemented/passing, or use production systems without explicit authorization and project safety evidence.

## Drift

If evidence contradicts project conventions or `project.md`, record the conflict under Drift in `06_automation_plan.md` and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
