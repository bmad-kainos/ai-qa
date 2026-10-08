---
name: qa-analyse-failure
description: Classify a test failure from a run, pasted log or CI URL using evidence and confidence, and safely iterate on test defects only.
argument-hint: "[run, pasted log, failed test, or CI run URL]"
---

# Analyse test failure
Classify each observed failure with evidence, confidence and the next evidence that would decide an uncertainty. Use non-causal wording: a failure or CI error alone does not establish its cause.

## When to use
Use with an execution record, pasted log or CI run URL, whether or not `qa-run-tests` was invoked first. For a CI URL, request read-only `ci.run.get` and/or `ci.test-results` through the configured provider/transport layer. The bounded fix loop changes test defects only; application changes and work-item creation are outside this skill.

## Reads
Always read `.github/ai-qa/project/project.md` for the environment, components, dependencies and test landscape; read `.github/ai-qa/project/conventions/testing.md` for the selected test path, commands and report format, `conventions/qa-process.md` for the configured fix loop and safe commands, and `conventions/integrations.md` for CI provider/transport. Read `.github/ai-qa/framework/method/{safety,discovery,failure-classes,artefacts,work-id-and-git}.md`, the selected pack, test/setup source, relevant implementation/contract evidence, and fresh `qa-work/<work-id>/` execution, design and baseline artefacts. If project files or prior artefacts are missing, gather minimum read-only session evidence and suggest `qa-configure`; never refuse solely because a run artefact is missing.

## Work-id
Resolve per `.github/ai-qa/framework/method/work-id-and-git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs
Accept a run or report, pasted output, failed test ID, or CI run URL. Gather exact assertion/error, expected and observed values, run ID/SHA/time, branch, environment, reproduction conditions, linked FR/NFR and available baseline. For CI data use `ci.run.get` / `ci.test-results` via configured integrations; if retrieval fails, retry once, then ask the user to paste the log or failure output (per `.github/ai-qa/framework/method/clarifying-questions.md`). If evidence is missing, inspect authorised read-only evidence or mark the evidence needed; never infer cause from a test title or a lone HTTP/CI error.

## Procedure
1. Reconstruct the failing step, preconditions and asserted contract. Preserve the original result; cite the exact log/report evidence, test and code paths, run, revision and environment. Separate observed facts, hypotheses and unknowns.
2. Compare the failure with the relevant acceptance criteria/specification and a same-environment, same-revision baseline where available. Use the framework and project-specific method in `failure-classes.md`; report each failure in one of these classes:

	 | Class | Evidence and confidence | What evidence would decide an uncertainty |
	 |---|---|---|
	 | Test defect | Test implementation, selector, fixture, stale expectation or nondeterminism evidence | A focused test/code inspection or comparable rerun |
	 | Application defect | Reproducible application result contradicting a confirmed requirement/contract | A controlled reproduction or application/contract evidence |
	 | Environment / infrastructure | Service, configuration, runner, resource or pipeline evidence distinct from application behavior | A healthy comparable environment/run or dependency diagnostic |
	 | Test data | Missing, contaminated, invalid or unauthorised fixture/account evidence | Verified isolated fixture and access/data state |
	 | Unknown | Evidence is absent, conflicting or insufficient | State the smallest discriminating check and required evidence |

	 State confidence (`high`, `medium` or `low`) per classification. Describe results as “consistent with”, “does not establish” or “evidence is insufficient”; do not assert unsupported root cause. Distinguish timing/order evidence from an ordinary test defect and do not call a test flaky from one failure.
3. Identify a minimal deterministic reproduction and environmental preconditions. A rerun must use the same revision and environment when possible. It is L3 when full, long, shared-service or environment-dependent unless the exact command is documented safe; obtain approval before it. A transient pass does not erase the original failure or establish a fix. Compare same-SHA reruns only when real history is available.
4. Give minimal remediation/next diagnostic step and owner, plus collateral regression tests. Fix test defects only, and only when explicitly requested or authorised by the workflow. On a non-default branch, change only test files created or modified in this work item. Never change product code, delete/skip/disable tests, or loosen assertions unless the relevant FR supports it.
5. Apply the bounded fix loop exactly: make one evidence-backed test-only fix; run the same targeted test with the documented command and required L3 approval; append the change, command, environment, result and evidence to `09_execution.md`; repeat only if the failure changed and another test-only fix is justified. Allow at most 3 iterations. Stop immediately when the same failure repeats, after iteration 3, when evidence is uncertain/blocked, or when the class is application defect, environment/infra or test data rather than a fixable test defect. Preserve the original run and every iteration. Do not retry an unsafe operation.
6. If evidence supports an application defect, offer `qa-bug-report`. Do not create a work item or publish automatically.

## Output
Append the analysis and every fix-loop iteration to `qa-work/<work-id>/09_execution.md`; save only redacted, safe supporting evidence under `qa-work/<work-id>/logs/`. Update `qa-work/<work-id>/index.md` with original and rerun status, classifications, confidence, evidence links, iteration count, current owner/action and approvals. Use:

```yaml
---
work-id: "<work-id>"
skill: "qa-analyse-failure"
framework-version: "<installed-version-or-unknown>"
created: "<UTC-ISO-8601>"
inputs:
  - source: "<run/log/CI URL/test/requirement path or link>"
    revision: "<run ID/SHA/document revision/observed time>"
---
```

Use this report structure:

```markdown
## Failure
- Test ID / original run / revision / environment:
- Expected:
- Observed:
- Evidence:
- Classification and confidence:
- Evidence that would decide uncertainty:
- Reproduction / comparable baseline:
- Impact and next owner/action:
- Status: original FAIL | rerun result | BLOCKED
- Drift:

## Fix-loop iterations
### Iteration <1-3>
- Test-only change and reason:
- Targeted command / approval:
- Revision / environment / run evidence:
- Result and remaining failure:
```

Clearly separate the original FAIL from any rerun and investigation status. Include no unredacted logs or unsupported root cause.

## Side effects and safety
| Action | Level | Gate |
|---|---:|---|
| Read run reports, logs, source and CI via `ci.run.get` / `ci.test-results` | L0 | None |
| Edit work-item-owned test files and append `09_execution.md` on a non-default branch | L1 | No separate gate; workflow plan approval first in orchestrated workflows |
| Rerun full, long, shared or environment-dependent tests | L3 | Explicit approval unless the exact command is documented safe |
| Create a bug/work item or publish | L4 | Separate exact destination/content approval through `qa-publish` |
| Install dependencies or change project configuration | L5 | Always; not performed by this skill |

Never mutate shared data, retry production traffic, edit product code, discard failures, expose secrets, or edit `.github/ai-qa/project/**`. Follow `.github/ai-qa/framework/method/safety.md`.

## Drift
If evidence contradicts project conventions or project.md, record it under Drift in the artefact and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
