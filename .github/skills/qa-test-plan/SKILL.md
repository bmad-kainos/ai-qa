---
name: qa-test-plan
description: Assemble an evidence-based ticket or sprint test plan with requirements, traceability, scenarios, automation, environment impact and the complete regression matrix; publishing is handled separately.
argument-hint: "[ticket, feature, sprint or work-item query; optional work-id]"
---

# Test Plan

Assemble analysis into a structured, traceable test plan. Ticket scope contains the required QA sections and full 13-area regression matrix; sprint scope adds test approach, prerequisites and effort. Show the QA Summary in chat. This skill drafts locally only: all publishing is handed off to `qa-publish` and follows the configured destination and timing.

## When to use

Use for a ticket, feature/spec, requirement set, sprint or supplied group of work items when a consolidated test plan is needed. It is independently invocable and gathers missing minimum inputs itself. Do not use it to publish a page, post comments, create branches or run tests.

## Reads

Always read `.github/ai-qa/project/project.md`: use Summary, Components, Environments, Data stores and external dependencies, CI/CD, Test landscape and Constraints. Read `.github/ai-qa/project/conventions/qa-process.md` (Test plan destination and timing, Definition of done and QA evidence, Scenario format, Work-id rule, Locale), `conventions/testing.md` (Scopes, Environments and base URLs, Test data rules), `conventions/integrations.md` for configured work-item search, and `conventions/git.md` for Ticket syntax. Read `.github/ai-qa/framework/method/traceability.md`, `dedup-rule.md`, `readiness.md`, `regression-areas.md`, `effort-estimation.md` for sprint scope, `safety.md`, `artefacts.md` and `precedence.md`. Optional prior artefacts: `requirement.md`, `context.md`, `coverage.md`, `design.md`, `regression.md`, `automation.md`, `review.md`, `index.md`.

Use `.github/ai-qa/framework/templates/test-plan.md` as the document template when present. If project context or template is absent, proceed from accessible evidence and mark the gap; suggest `qa-configure` for missing project configuration.

## Work-id

Resolve per `.github/ai-qa/framework/method/git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs

Accept a ticket key, feature/spec, list of work items, sprint/backlog bucket, provider-supported JQL/WIQL, or existing QA artefacts. For a single key call `workitem.get`; for a sprint/query call `workitem.search`. Provider, deployment and transport come from `conventions/integrations.md`; if the preferred transport fails, report the failure and try the configured fallback. Manual fallback: ask the user to paste item text/list. Never assume a Jira/Confluence host or require an external page.

If prior artefacts are missing, gather the minimum yourself; never refuse. Derive stable FR/NFR IDs, inspect relevant test evidence, design lean scenarios, assess automation and complete regression analysis when these inputs are not supplied. Distinguish evidence from provisional analysis, never invent test results, and do not compare implementation with a ticket without confirmed branch evidence.

## Procedure

1. Resolve scope and fetch only the requested work items. In sprint scope, preserve each ticket's source and stable local IDs; prefix IDs with the work-item key in cross-ticket summaries to avoid collisions. List inaccessible or excluded items and do not fabricate results for them.
2. Reuse current prior analyses when available. Otherwise derive requirements, readiness, coverage verdict, manual scenarios (configured format) and automation decisions from the minimum accessible evidence. Keep distinctions among assessed, automated, deliberately not automated and executed. Include a traceability matrix linking each FR/NFR to existing evidence, scenarios, automation decision, test files and last result.
3. Complete the regression matrix with all 13 areas and justified risk levels. Never omit it for ticket scope. For every HIGH/CRITICAL area include targeted scenarios, automation reinforcement, production impact and rollout validation as applicable.
4. Produce the ticket sections listed below, in order. Use configured locale (default en-GB unless conventions specify otherwise). In sprint scope also add the sprint-level approach, prerequisites and effort sections. For effort estimation use `.github/ai-qa/framework/method/effort-estimation.md`; state assumptions and units, do not invent hours.
5. Show the complete QA Summary in chat. The summary columns are `Ticket · Readiness · Max risk · Coverage verdict · Scenarios written/not written · Automated/manual/not needed · Run result · Published`. Use actual readiness, maximum matrix risk, evidence-based coverage, written/omitted counts, justified decision, `Not run` absent results and `No` absent a publication receipt.
6. Save the final local plan and update the index. If design approval is required by the workflow, show the draft and obtain explicit approval before marking it final; standalone local writing does not itself require an L1 gate. This skill does not publish. Hand off to `qa-publish`, which must honour `conventions/qa-process.md` → Test plan destination and timing and the exact-payload L4 gate.

### Ticket-scope sections

Include all of these sections, in this order:

1. **Summary** — brief description of the item and test scope.
2. **QA Summary** — one-row ticket table, also shown in chat.
3. **Risk** — key risks, assumptions and mitigations.
4. **Requirements** — functional `FR1…` and non-functional `NFR1…`, edge cases, flags, integrations and ambiguities; preserve IDs.
5. **Traceability Matrix** — requirement → existing evidence → scenarios → automation decision → test files → last result. Separate assessed, automated and deliberately not automated.
6. **Scenarios** — numbered scenarios from design in the project's configured Scenario format (`method/scenario-format.md`), with requirement IDs, categories, environment/setup/cleanup and observable results, followed by **Scenarios Not Written** and reasons.
7. **Automation** — justified per-scenario automate/manual/not-needed decision and impact.
8. **Regression Impact** — affected existing behaviors and targeted HIGH/CRITICAL checks.
9. **Environment Impact** — environment/configuration, access, dependencies and blockers.
10. **Open Questions** — unresolved ACs, assumptions, owners and decisions.
11. **Regression Matrix** — all 13 standard areas plus configured extra regression areas.

### Sprint-scope additions

In addition to ticket-scope content, add:

- **Test Approach** — scope and approach by ticket/level, including prioritisation and shared behavior.
- **Prerequisites** — environment/access, external dependencies, safe test data, tools and dependent work, with status/owner.
- **Effort** — estimate by applicable category using `framework/method/effort-estimation.md`; include assumptions and units, and sum only comparable estimates. Do not use Jira/Feabhas-specific hour bands unless configured as a team option.
- Per ticket, preserve source, readiness, ticket-local requirement IDs, scenarios, risk and automation decision; consolidate shared environments, dependencies, execution priority and blockers in the sprint summary.

Do not fabricate ticket lists when a sprint/query is inaccessible; report the provider failure and use the configured fallback, or ask the user to paste the list. Do not add author/project/sprint metadata that was not supplied or resolved from evidence.

### QA Summary template

```md
| Ticket | Readiness | Max risk | Coverage verdict | Scenarios written/not written | Automated/manual/not needed | Run result | Published |
|---|---|---|---|---|---|---|---|
| <key> | <Green/Amber/Red/Unknown> | <LOW/MEDIUM/HIGH/CRITICAL> | <Pass/Needs Improvement/Insufficient/Not assessed> | <written>/<not written> | <decision> | <Not run/PASS/FAIL/BLOCKED with evidence> | <No or confirmed receipt> |
```

Do not claim publication until `qa-publish` returns a receipt/link. Do not claim tests pass without current run evidence. Mark unavailable information explicitly and list it as an open question or blocker.

### Scenario rendering handoff

When a later, explicitly approved publication targets Confluence, `qa-publish` formats the **scenarios-only** content using the provider's rules; never put plan analysis on that scenarios page. Preserve the source format requirements defined in `.github/ai-qa/framework/method/scenario-format.md` (Publishing to Confluence): each scenario has a sequential zero-padded H3 `Test Scenario 01 — <Scenario Title>` (blue `rgb(0,82,204)` when rendered in Confluence). In `bdd` the GIVEN/WHEN/THEN/AND labels are bold, each step is on its own line with a blank evidence placeholder after it. In `steps` the body is a table with `#`, `Action`, `Expected result` and an empty `Evidence` column, with Preconditions above and Cleanup below. Verification CLI/SQL/API snippets follow the applicable step in a code block. After each scenario include only `Result`, `Status: PASS / FAIL / BLOCKED`, and `Notes`. This is a handoff format only; this skill does not publish or generate a Confluence page.

## Output

Write `qa-work/<work-id>/outputs/test-plan.md` with front matter `work-id`, `skill: qa-test-plan`, `framework-version`, `created` (UTC ISO date/time) and `inputs` (work items, source revisions and prior artefact revisions). Update `qa-work/<work-id>/index.md` with plan link, FR/NFR traceability, readiness, max risk, coverage verdict, scenario counts, automation choice, run and publication status with evidence, open questions and design approval status. Present QA Summary in chat for both ticket and sprint scope.

## Side effects and safety

| Action | Level | Gate |
|---|---|---|
| Read project files, prior artefacts and `workitem.get`/`workitem.search` | L0 | None |
| Write local test plan and index on a non-default branch | L1 | No gate for standalone artefact; summarise changes. Workflow L1 plan gate remains separate. |
| Run environment-dependent tests or alter test data | L3 | Not performed; separate explicit gate |
| Publish a plan, post a comment or update a work item | L4 | Not performed here; exact payload/target approval through `qa-publish` |
| Install tools or change adaptation-layer files | L5 | Not performed; `qa-configure` only for project-owned files |

Never switch branches, create a branch or commit as an implied follow-up. Never publish directly from this skill or call Jira/Confluence-specific tools. Publication timing and destination come from project conventions.

## Drift

If evidence contradicts project conventions or `project.md`, record the conflict under Drift in `test-plan.md` and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
