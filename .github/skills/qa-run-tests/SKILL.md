---
name: qa-run-tests
description: Run all, path, tag or risk-selected tests using configured project commands; use to produce evidence-based execution results.
argument-hint: "[all, path, tag, risk subset, work-id, and environment]"
---

# Run tests
Execute the requested test scope using the project's documented commands and report only what the run evidence supports. A test run does not itself authorise changes, dependency installation or external writes.

## When to use
Use to run all tests, a path/node, a tag, or a risk-selected subset. Use `qa-analyse-failure` to classify a failure and `qa-generate-tests` to create tests. If the project layer is absent, derive the minimum runner and environment information from read-only evidence and state uncertainty; do not invent a command.

## Reads
Always read `.github/ai-qa/project/project.md` for the test landscape, CI, environments, dependencies and environment classification; read `.github/ai-qa/project/conventions/testing.md` `Scopes`, `Commands`, `Reports`, `Environments and base URLs`, `Test data rules` and `Manual testing ownership` sections. Read `conventions/qa-process.md` for `Commands safe to run` and fix/run rules, and `conventions/integrations.md` for CI provider/transport details. Read `.github/ai-qa/framework/method/{safety,discovery,artefacts,work-id-and-git}.md`, the selected pack and relevant runner/CI configuration. Reuse only fresh `qa-work/<work-id>/` index, plan, baseline and prior execution evidence. If project files or prior artefacts are missing, use read-only session evidence and suggest `qa-configure`; never refuse solely for missing artefacts.

## Work-id
Resolve per `.github/ai-qa/framework/method/work-id-and-git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs
Take the requested scope (`all`, path/node, tag, or risk), work ID, target revision, environment and any required data/reset/cleanup constraints. Gather missing selector and test context from `conventions/testing.md`, the repository, and prior artefacts; never refuse because an upstream plan is absent. Determine whether the environment is local, shared, deployed or production-facing from `project.md`. If the user did not name a scope, propose the narrowest useful subset instead of silently running all tests.

## Procedure
1. Inventory matching tests, requirements/risk links, known skips/quarantines, dependencies, cleanup and existing fresh runs. Confirm current branch, commit, selected files, worktree state and environment classification. Do not infer coverage from names alone.
2. Resolve the command from `conventions/testing.md` `Commands`: use its `all`, `path`, `tag` or `list-help` entry as applicable. For a risk-selected subset, select existing cases from requirement-to-test traceability and regression/risk evidence, then use the documented path/tag command. Never invent a package script, runner flag or environment URL. Confirm documented `lint-compile` only when that is the requested validation, not as a substitute for execution.
3. Before a gated run, show the exact command and selector, target revision, environment, expected duration, data effects, cleanup, reports/log destination and reason for the scope. A full suite, shared/environment-dependent run or long run is L3 unless the exact command is listed as safe in `conventions/qa-process.md`. Proceed only after explicit affirmative approval. A narrower run is also L3 when it has environment-dependent or shared-service effects.
4. Run the approved command and capture the exact command, environment, start/end time, exit code, test identifiers and report/log paths. Parse available JUnit XML, TRX, pytest JSON, Playwright JSON or console output. Prefer structured reports; do not infer totals from incomplete/truncated output. Record passed, failed, skipped, blocked and not-run distinctly. A zero exit code without usable run evidence is not enough to claim PASS.
5. Classify the environment outcome from `project.md`. Missing dependency or infrastructure is `BLOCKED`, not an application failure; dependency installation is a separate L5 action. Do not label unavailable tests as passed. Perform only documented test-data cleanup, and report cleanup failure separately. Never rerun an unsafe or shared operation without the required gate.
6. Compare against an available baseline only when revision, environment and configuration are comparable. Separate known failures from new observations, disclose incomparable or stale evidence, and offer `qa-analyse-failure` for failures.

## Output
Write the execution summary to `qa-work/<work-id>/09_execution.md` and safe, redacted run logs/reports to `qa-work/<work-id>/logs/`. Update `qa-work/<work-id>/index.md` with scope, revision, environment, command, result, failed IDs, artefact links, status and any approval/gate log. Each Markdown artefact uses:

Open the artefact with **Result** (one-sentence verdict) and **Do next** (max 3 ordered actions) lines per `templates/artefact.md`. If the numbered file is absent, read legacy `execution.md` as a fallback; always write the new name and never silently rename.

```yaml
---
work-id: "<work-id>"
skill: "qa-run-tests"
framework-version: "<installed-version-or-unknown>"
created: "<UTC-ISO-8601>"
inputs:
	- source: "<test/plan/run/config path or link>"
		revision: "<commit/run ID/document revision/observed time>"
---
```

Use this execution record template:

```markdown
## Run
- Scope / selector:
- Command:
- Revision:
- Environment classification:
- Started / completed:
- Exit code:
- Result: PASS | FAIL | BLOCKED | Not run
- Counts: passed / failed / skipped / blocked / not run
- Failed test IDs:
- Report and log evidence:
- Data effects / cleanup:
- Comparability and known failures:
- Drift:
```

PASS requires observed successful execution evidence; FAIL requires observed failing tests; incomplete runs are BLOCKED or Not run. Never write `PASS` merely because a command was proposed, started, or returned without a parseable result. Raw logs containing secrets or sensitive data are not saved or committed.

## Side effects and safety
| Action | Level | Gate |
|---|---:|---|
| Read test, project, CI and prior run evidence | L0 | None |
| Execute a documented, safe local targeted run | L0 | None when explicitly listed safe and no shared/environment-dependent effects |
| Execute full, long, shared or environment-dependent tests | L3 | Always, unless the exact command is listed safe in `qa-process.md` |
| Install dependencies or alter project configuration | L5 | Always; not performed by this skill |
| Write `09_execution.md` and logs on a non-default branch | L1 | No separate gate; workflow plan approval first in orchestrated workflows |
| Publish results or create a work item | L4 | Separate explicit approval via `qa-publish` |

Never run production-facing, destructive, migration, deployment or load commands as a test run. Never suppress failures, change thresholds, mark skipped cases as passed, expose credentials, edit `.github/ai-qa/project/**`, or modify tests automatically.

## Drift
If evidence contradicts project conventions or project.md, record it under Drift in the artefact and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
