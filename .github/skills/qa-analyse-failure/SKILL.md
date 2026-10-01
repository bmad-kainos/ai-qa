---
name: qa-analyse-failure
description: Diagnose a failed test from actual logs, assertions and code; distinguish product defects, flaky tests, data and environment faults.
argument-hint: "[failed test, CI run, report or pasted error]"
user-invocable: true
---

# Analyse a test failure

## 1. Trigger and scope
Invoke directly for a failing assertion, test report, CI run or observed defect. Analyse first; do not automatically repair code, rerun against shared services or file a bug. No prior `qa-run-tests` invocation is necessary.

## 2. Inputs
Collect failing test ID, exact assertion expected/actual, log/run URL, branch/commit, environment, reproduction steps and linked FR/NFR ID. Accept pasted CI output or a work ID without requiring a provider. If evidence is absent, request it or inspect authorised logs; never infer root cause from a title. Recheck `qa-work/<work-id>/index.md` against ticket/run revision before relying on earlier classification.

## 3. Context and prerequisites
Read `.github/ai-qa/framework/method/safety.md`, `discovery.md`, `failure-classes.md` and `artefacts.md`; `.github/ai-qa/project/project.md` and named `conventions/testing.md`, `qa-process.md` and `integrations.md` if present, then other approved `conventions/*.md` (otherwise derive read-only session context), selected pack, test source/setup, changed implementation and baseline/known failures. Use configured provider recipe only for authorised external diagnostics; classify from evidence, not generic stack assumptions.

## 4. Procedure
1. Reconstruct the failing step, preconditions and asserted contract; cite log lines and test/code paths.
2. Compare against AC/specification and compatible baseline. Separate product regression, incorrect/obsolete expectation, intermittent/flaky timing or order, test data, dependency/infrastructure and configuration; do not treat an HTTP or CI error alone as proof of a product defect. Distinguish observed fact, hypothesis and unknown.
3. Look for a minimal deterministic reproduction and expected environmental preconditions. If safe and authorised, rerun only the failing selector with the same revision/environment and capture differences; a transient pass does not establish a fix. Compare same-SHA reruns only where supported by real run history.
4. Rank hypotheses by evidence/confidence, state disconfirming evidence and propose minimal remediation or next diagnostic step and owner. Identify collateral regression tests. If explicitly asked to fix an owned **test** defect, present intended paths/diff, then change only work-item-owned tests on a non-default branch (standalone: no extra L1 gate; orchestrated: approved L1 plan) and validate in **at most three** evidence-backed fix/rerun iterations. Stop and report unresolved failures; never fix product code.

## 5. Safety gates
Do not mutate shared data, delete/skip a test, weaken or disable assertions, update a snapshot to hide a regression, retry production traffic or leak logs/secrets to justify a green result. Standalone requested test-only fixes are ungated locally; orchestrated work requires **L1** plan approval, and environment-dependent reruns require **L3** approval. Never edit product code or assert an unsupported root cause.

## 6. Outputs and evidence
Requested saved artefacts require YAML frontmatter `work-id`, `skill: qa-analyse-failure`, `framework-version` (installed or `unknown`), `created` (UTC ISO) and `inputs` (run/report/source artefacts and revisions). Standalone local index updates need no extra gate; orchestrated writes follow L1 plan approval.

Return test/run/commit/environment, expected versus observed, classification and confidence, cited log/assertion evidence, reproduction status, impact, unknowns and next owner/action. Clearly separate original **FAIL**, rerun result and **BLOCKED** investigation. If an authorised report is saved under `qa-work/<work-id>/outputs/`, add frontmatter for work ID, source revision, run SHA/time, skill, evidence and approvals and link it in `index.md`; mark stale analysis on input drift. Never persist unredacted logs.

## 7. Standalone and handoff
Resolve work ID from explicit input, then a branch ticket according to confirmed `.github/ai-qa/project/conventions/git.md` if present, else `adhoc-YYYYMMDD-<safe-slug>` (not a ticket). Gather minimal error/test evidence when earlier steps are absent. Recheck source/config/branch/run drift; for project-layer changes suggest `qa-configure refresh`, never edit project files here.

Work directly from a pasted log or CI artefact without requiring `qa-run-tests`. If evidence supports a product defect, offer `qa-bug-report`; if a test defect, suggest a focused fix and rerun, not an automatic ticket or publication.
