---
name: qa-automation-plan
description: "Decide whether integration/E2E automation adds value, then plan scope, levels, fixtures, mocking, environment and CI using the project's existing stack."
argument-hint: "[ticket, feature, requirements or candidate scenarios]"
user-invocable: true
metadata:
  output: "Automation decision and inventory: qa-work/<work-id>/automation.md"
  index-update: "Decision, FR/NFR links, CI/environment blockers, provenance and approval"
---

# Integration and automation evaluation

## Context

Accept a ticket, change, ACs or proposed manual scenarios; derive stable `FR`/`NFR` IDs if needed. Read `.github/ai-qa/framework/method/safety.md`, `discovery.md`, `.github/ai-qa/project/project.md`, applicable `.github/ai-qa/project/conventions/*.md`, and `.github/copilot-instructions.md` if present; use actual test framework, CI configuration, available requirements, tests and risk evidence, never framework defaults as project facts. Confirm the target branch before comparing implementation. Use previous analyses only if fresh; otherwise derive from user input and inspected code. Never assume Python, Playwright, AWS, an Atlassian MCP, a particular runner or prior skills. If an environment/credential is unknown, plan around the blocker rather than fabricating it.

## Decision rubric (Generic POC step 04)

Answer **each** with yes/no/unknown and reason: cross-service/component impact; API routes/contracts/gateway changes; core backend logic; database reads/writes; feature flags; caching/staleness; authentication/authorisation; logging validation; environment-dependent configuration. Consider existing test evidence, risk, cost, stability and which outcomes manual testing alone cannot protect. No new automation is a valid recommendation for low-risk internal changes with adequate developer-owned unit coverage.

If justified, specify:

- Requirement IDs and end-to-end scope, test level (unit developer-owned, integration single boundary, E2E multi-system), proposed behaviour assertions and a small Gherkin example covering success and a relevant failure/flag state.
- Existing framework, test location/file naming, fixtures/data lifecycle and safe ticket-linked IDs with natural display names; reuse existing conventions. Do not create a new framework when one exists.
- Real versus mocked boundaries (mock external dependencies, not the behaviour/contract under test), environment/provider-specific dependencies and secrets via approved configuration only; cleanup and isolation.
- CI markers/suites, triggers, runtime and flake risk, dependency readiness, ownership and effort **None/Low/Medium/High** (Low small addition, Medium new scenarios/file, High new fixtures/framework), and whether existing tests already suffice.

For API automation, first inspect the published OpenAPI/schema if available and the project's existing API tests. Inventory each applicable endpoint's happy path (minimal valid and full payload if specified), missing required fields, invalid types/nulls, missing/invalid authentication where required, response schema, content negotiation if specified, and **at least two boundary cases per constrained field**; assert both status and error-body structure. Parameterise repeated cases in the configured test framework. Follow the documented contract rather than guessing response codes, and justify omissions or existing coverage. Do not translate this into redundant manual scenarios.

If **not** justified, state why, what developer tests cover, what manual check suffices and residual risks. Distinguish proposed scenarios from implemented or passing automation. Output a clear yes/no/deferred decision, evidence, actionable plan or manual alternative, blockers and traceability. Follow `safety.md`: L0 read-only; L1 workflow-plan approval only for orchestrated local edits, not standalone local artefacts; L2 branch/commit, L3 shared/full test execution, L4 exact external write/push, L5 installation/project adaptation require independent approval. No product-code changes or secrets. Recheck requirements, test inventory and CI before reusing a plan.

## Work record and handoff

Before local artefact/index edits confirm a non-default branch. Follow `.github/ai-qa/framework/method/git.md` for safe work-ID matching (including its confirmed-key fallback) and `artefacts.md` for provenance: `inputs` lists all decision-relevant source revisions; if **any** becomes newer, mark this and dependent analyses stale.

Also read `.github/ai-qa/project/conventions/discovery.md` when present; only `qa-configure` may refresh it.

Resolve work ID: explicit user ID/ticket → branch ticket matching `.github/ai-qa/project/conventions/git.md`'s configured pattern → `adhoc-YYYYMMDD-slug`; never guess absent a pattern, and reuse a matching index without changing precedence. Read `.github/ai-qa/project/project.md`, `conventions/git.md`, `testing.md`, `qa-process.md`, `integrations.md` and `reporting.md` if present; consult `.github/ai-qa/framework/method/precedence.md`, `artefacts.md` and the selected pack, not an assumed stack. Gather missing minimum requirements/test inventory rather than require prior outputs. Write `qa-work/<work-id>/automation.md` with YAML front matter `work-id`, `skill: qa-automation-plan`, `framework-version` (installed version or `unknown`), `created` (UTC ISO date/time) and `inputs` (source/revision); update `qa-work/<work-id>/index.md` with decision, requirement links, evidence/branch, blockers, CI impact and link. Standalone local writing needs no L1 approval; orchestrated workflows do. Hand off to `qa-generate-tests` only if asked; record contract, test-stack or environment drift and suggest re-planning or `qa-configure` for persistent updates.
