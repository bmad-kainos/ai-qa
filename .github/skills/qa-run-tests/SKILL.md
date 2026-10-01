---
name: qa-run-tests
description: Run the project's existing targeted test suite safely and report evidence-based pass, fail and blocked results.
argument-hint: "[ticket, test selector, suite and optional environment]"
user-invocable: true
---

# Run tests

## 1. Trigger and scope
Invoke directly to execute existing tests for a ticket, changed area or named suite. Execution is distinct from generation, bug filing and publishing; do not silently modify tests. A standalone targeted run requires no upstream artefact.

## 2. Inputs
- Determine requested work ID/ticket, test selector, environment, target revision, expected command, fixtures and cleanup. If no scope is specified, propose a narrow selector from repository evidence rather than running the whole suite.
- Use current `qa-work/<work-id>/index.md` and approved plan if available, but confirm their ticket/branch/config revisions; otherwise identify relevant tests from repository paths. Clarify ambiguous or risky targets before execution.

## 3. Context and prerequisites
Read `.github/ai-qa/framework/method/safety.md`, `discovery.md` and `artefacts.md`; `.github/ai-qa/project/project.md` and named `conventions/testing.md`, `qa-process.md`, `integrations.md` and `git.md` if present, then other approved `conventions/*.md` (otherwise derive read-only session context); selected framework pack, CI configuration and scripts. Resolve commands from documented runner, not guessed tooling. For external services select the confirmed transport/deployment recipe. Check access without printing credentials, environment policy, test-data isolation, expected side effects and cleanup.

## 4. Procedure
1. Inventory matching tests and check known skips/quarantines, service dependencies and current baseline. Verify selected test files and branch match the requested work; record `sha` and clean/dirty status.
2. Choose the smallest existing targeted command that covers requested behaviour; show selector, branch/commit, environment, data effects, cleanup and evidence destination. Expand to full suite only with justification and L3 approval.
3. For explicitly safe, local targeted tests execute the command and capture exit code, counts (passed/failed/skipped), failing identifiers and report/log locations. For full/environment-dependent runs or shared/non-local environments, present scope and side effects and get explicit action-specific approval before running.
4. If dependencies or infrastructure are missing, stop as **BLOCKED** with diagnostic evidence; do not install packages without L5 or label infrastructure a product failure. Restore/clean test-owned data according to the approved project recipe; report cleanup failure independently.
5. Compare results with expected ACs and a *same-environment, same-revision* baseline when available; report regressions separately from known failures and disclose incomparable baselines. Recheck run metadata and report timestamps to avoid stale results. Suggest `qa-analyse-failure` for triage.

## 5. Safety gates
Never run production-facing, destructive, migration, deployment or load commands under a test-run request. Require **L3** approval for full, environment-dependent or shared-service runs unless specifically documented safe locally; **L5** for dependency installation. Never bypass safety checks, change thresholds, suppress failures or mark skipped tests as passing. Do not expose credentials or sensitive logs in reports. Never retry an unsafe operation without approval.

## 6. Outputs and evidence
Requested saved artefacts need YAML frontmatter `work-id`, `skill: qa-run-tests`, `framework-version` (installed or `unknown`), `created` (UTC ISO) and `inputs` (test/plan/run artefact links with revisions). Standalone local index updates are ungated on a non-default branch; an orchestrated workflow first needs L1 plan approval.

Report command/selector, commit, environment, timestamp, exit status, totals (passed/failed/skipped/blocked), failed IDs, log/report links and cleanup status. Use **PASS** only for observed success, **FAIL** for observed test failures and **BLOCKED/Not run** for incomplete runs; mark unknowns. When a saved run summary was requested, persist it in `qa-work/<work-id>/outputs/` with frontmatter (work ID, source revision, branch/commit, skill, environment, run time, selector, evidence provenance) and update `index.md` status/links without committing raw logs or secrets. Reuse only fresh prior runs.

## 7. Standalone and handoff
Resolve work ID: explicit ID first, then a branch ticket per confirmed `.github/ai-qa/project/conventions/git.md` if present, else `adhoc-YYYYMMDD-<safe-slug>`; never invent a ticket. Gather minimal selector/environment/test conventions if a prior plan is missing. On source/config/branch drift refresh dependent results and suggest `qa-configure refresh` for configuration, never edit project files.

When invoked without prior skills, discover tests and runner yourself. Suggest `qa-analyse-failure` with failing IDs and logs or `qa-publish` after review; do not publish or change code automatically.
