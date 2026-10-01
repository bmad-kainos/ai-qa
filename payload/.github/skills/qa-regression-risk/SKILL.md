---
name: qa-regression-risk
description: Independently assess change-related regression exposure in a complete 13-area matrix; use with a diff, ticket, feature, description or release scope.
argument-hint: "[diff, ticket, change, feature or release scope; optional work-id]"
---

# Regression Risk

Evaluate system-wide impact beyond the immediate scope of a change. The 13-area matrix forces systemic thinking and prevents purely local validation. A complete matrix is mandatory in every test plan, and this skill is fully independent of other analyses.

## When to use

Use at any point to assess a diff, ticket, feature, change description or release scope. It can operate from any one of these inputs and does not require previous artefacts. Use when prioritising regression checks, rollout validation or risk-driven QA effort. Do not use as a substitute for observed test results.

## Reads

Always read `.github/ai-qa/project/project.md`: use Components, Data stores and external dependencies, Environments, CI/CD and Constraints. Read `.github/ai-qa/project/conventions/qa-process.md` (Extra regression areas, Definition of done and QA evidence, Work-id rule), `conventions/git.md` (Ticket syntax and Branch patterns), and `conventions/testing.md` (Scopes) as relevant. Read `.github/ai-qa/framework/method/regression-areas.md`, `safety.md`, `artefacts.md`, `precedence.md`. Optional prior artefacts: `requirement.md`, `context.md`, `coverage.md`, `design.md`, `automation.md`, `index.md`.

If project context is missing, inspect available evidence, identify uncertainty and suggest `qa-configure`; never refuse due to absent upstream artefacts.

## Work-id

Resolve per `.github/ai-qa/framework/method/git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs

Accept a diff/commit, ticket, feature, pasted change description or release scope. If a ticket key is supplied and its provider is configured, use `workitem.get`; provider and transport come from `conventions/integrations.md`. If the preferred transport fails, say so and fall back; manual fallback is pasted ticket text. Assess from whatever evidence is available. If implementation is unavailable, score stated design provisionally. Never equate missing evidence with LOW risk.

If prior artefacts are missing, gather the minimum yourself; never refuse. This skill is read-only apart from its QA work artefact. It does not require a branch checkout.

## Procedure

1. Establish scope, source revision, affected components and dependencies. Map project components and dependencies to the matrix areas below; note which areas have no evidence and why. Include project-configured `Extra regression areas` from `conventions/qa-process.md` as additional rows without replacing or renaming the 13 standard areas.
2. For **every** standard area, assign **LOW**, **MEDIUM**, **HIGH** or **CRITICAL**, explain the evidence/uncertainty, and state whether regression and automation updates are needed (`Yes / No / Unknown`). Never mark every area LOW without an individual justification.
3. Apply escalation rules. Escalate when feature flags modify runtime behavior; logic is environment-dependent; caching or async behavior is involved; database schema or persistence changes; endpoint-level gating is introduced; or authentication/authorization changes. Domain facts may warrant further escalation: record the evidence rather than mechanically lowering risk.
4. For each HIGH or CRITICAL area, additionally propose targeted regression scenarios, recommend automation reinforcement, highlight potential production impact, and suggest rollout validation strategy if applicable. CRITICAL requires immediate attention; do not state a clean regression or safe rollout absent actual evidence.
5. Optionally rank areas or multiple tickets using Change Impact (1–5) × Failure Criticality (1–5), explaining both scores and modifiers. This ranking supplements and does not replace the mandatory matrix. Scores: impact 5 core auth/payments/data writes/primary journey, 4 important/widespread feature, 3 supporting workflow/internal tooling, 2 minor/low-traffic path, 1 cosmetic/docs/config; criticality 5 outage/data loss/security/regulatory breach, 4 core feature or revenue/major user impact, 3 degradation with workaround, 2 minor recoverable inconvenience, 1 no user impact.
6. Optional modifiers: recently changed code with no existing tests `+5`; known flaky area/bug history `+3`; external service/integration `+2`; high-quality automated coverage `−3`; explicitly out of release scope forces `0`. Show raw and adjusted scores. Ties go to higher Failure Criticality; items with no test coverage rise one tier. Explain any domain override. Priority guidance: Must Test ≥16; Should Test 6–15; Smoke/Spot Check 3–5; Skip ≤2.

### Risk levels

| Level | Meaning |
|---|---|
| **LOW** | Minimal impact; existing tests appear sufficient |
| **MEDIUM** | Some impact; targeted testing recommended |
| **HIGH** | Significant impact; regression testing required |
| **CRITICAL** | Could break core functionality; immediate attention needed |

### Standard regression risk matrix

| Area | Risk Level | Why? | Regression Needed? | Automation Update Needed? |
|---|---|---|---|---|
| API Behaviour | | | | |
| Existing Endpoints | | | | |
| Feature Flags | | | | |
| Caching | | | | |
| Authentication / Authorisation | | | | |
| API Gateway | | | | |
| Backend Logic | | | | |
| Database Layer | | | | |
| Data Integrity | | | | |
| Logging / Monitoring | | | | |
| Environment Configuration | | | | |
| CI/CD Pipeline | | | | |
| Backward Compatibility | | | | |

## Output

Write `qa-work/<work-id>/regression.md` with front matter `work-id`, `skill: qa-regression-risk`, `framework-version`, `created` (UTC ISO date/time) and `inputs` (ticket/diff/branch/source revision). Include scope and confidence, the complete 13-area matrix, project extra areas, highest overall risk, targeted scenarios/automation/production impact/rollout validation for each HIGH/CRITICAL area, optional ranked scores, assumptions and open questions. Update `qa-work/<work-id>/index.md` with the highest risk, matrix link, branch/source revision, mitigations and unknowns. Present highest risks and urgent actions in chat.

## Side effects and safety

| Action | Level | Gate |
|---|---|---|
| Read diff, ticket, project context and existing tests | L0 | None |
| Write `regression.md` and update `index.md` on a non-default branch | L1 | No gate; summarise changes |
| Run tests, inspect live systems, change feature flags or validate rollout | L3 | Not performed; separate approval required |
| Publish or comment externally | L4 | Not performed; hand off to `qa-publish` |
| Edit project conventions | L5 | Never performed; `qa-configure` only |

## Drift

If evidence contradicts project conventions or `project.md`, record the contradiction under Drift in `regression.md` and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
