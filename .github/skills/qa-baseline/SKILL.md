---
name: qa-baseline
description: Capture a reproducible before-change QA baseline for a ticket or target branch without hiding existing failures.
argument-hint: "[ticket, area, base ref or test selector]"
user-invocable: true
---

# Establish QA baseline

## 1. Trigger and scope
Invoke directly (`qa-baseline snapshot` or a bounded request) before assessing a change, comparing runs or inspecting existing quality. Capture relevant existing behaviour and failures, not an invented clean slate. No prior workflow required.

## 2. Inputs
Identify work ID/ticket or feature, base reference, changed area, environment, period and test selector. Work ID may be a bounded investigation, not a fabricated issue key. If no base is supplied, inspect confirmed project/repository default and verify the ref before comparing. Decide whether a read-only historical snapshot suffices or execution was explicitly requested.

## 3. Context and prerequisites
Read `.github/ai-qa/framework/method/safety.md`, `discovery.md`, `artefacts.md` and `traceability.md`; `.github/ai-qa/project/project.md` and named `conventions/testing.md`, `qa-process.md`, `reporting.md` and `git.md` if present, then other approved `conventions/*.md` (otherwise derive read-only session context), selected pack, test scripts, CI artefacts and prior run reports. Use configured provider recipes only for authorised external read/execute operations. Record current ref and dirty state without altering the user's work; do not assume CI data exists or use a baseline from a different environment as comparable.

## 4. Procedure
1. Record baseline commit/ref, timestamp, environment/config identity, source requirement revision and FR/NFR/scenarios in scope. List known gaps and planned exclusions.
2. Inventory existing test files and *assertions*, not only names, and documented known failures. Prefer a trusted CI result for the exact ref/environment with run ID/time; otherwise propose the smallest safe existing targeted command under `qa-run-tests` rules. Do not automatically run tests for a read-only snapshot request.
3. Record counts, failures/skips, report links and gaps; distinguish tests not run from passed and pre-existing failures from new regressions. If prerequisites are unavailable, record **partial/BLOCKED** baseline with reason. Compare only like-for-like revisions/environments; report an incomparable baseline explicitly.
4. Present the snapshot in chat. If persistence was requested, save under `qa-work/<work-id>/outputs/` and update `index.md` (standalone: no extra L1 gate; orchestrated: approved L1 plan), recording source/freshness and superseded snapshots. Never overwrite an existing baseline without showing differences and confirming the target. Optional `tools/qa-stats.py` from this framework checkout computes percentiles/same-SHA reruns/flakiness only with sufficient history; otherwise label **Not computed**.

## 5. Safety gates
Do not checkout/reset branches, mutate shared data, run destructive commands, silently rerun production tests or change thresholds. Standalone scoped local snapshot edits need no extra gate; orchestrated work requires **L1** plan approval, and non-local/full execution **L3** approval. Never write `.github/ai-qa/project/`: only `qa-configure` owns that layer. Do not call an unexecuted suite green.

## 6. Outputs and evidence
Requested saved snapshots need YAML frontmatter `work-id`, `skill: qa-baseline`, `framework-version` (installed or `unknown`), `created` (UTC ISO) and `inputs` (CI/run/test artefact paths or links and revisions). Standalone local index updates need no extra gate on a non-default branch; orchestrated writes follow L1 plan approval.

Return source revision, ref/commit, environment/config, command or CI run, timestamp, totals, known failures, missing coverage, result status and evidence links. Clearly state comparability limits. Approved saved snapshots need frontmatter (`work-id`, skill, requirement revision, branch/commit, environment, timestamp, evidence, approval), linked from `qa-work/<work-id>/index.md`; on drift mark old evidence stale and do not silently reuse it.

## 7. Standalone and handoff
Resolve work ID from explicit ID, branch ticket according to confirmed `.github/ai-qa/project/conventions/git.md` if present, or `adhoc-YYYYMMDD-<safe-slug>` (never a fabricated ticket). With no prior plan gather the minimal ref, test inventory and run evidence. On ticket/config/ref drift mark old baseline incomparable; recommend `qa-configure refresh` for project-layer changes, not edits here.

Baseline collection needs no prior workflow output. Pass the recorded scope and failure IDs to `qa-run-tests`, `qa-analyse-failure` or a later regression assessment; no automatic publish or branch creation.
