---
name: qa-baseline
description: Snapshot or compare test inventory, coverage and CI history without implying causation or inventing statistics.
argument-hint: "[snapshot|compare, reference/date range, and optional CI history depth]"
---

# QA baseline
Capture a reproducible view of the current test and CI evidence, or compare two periods/snapshots. Preserve existing failures and clearly separate observed data from missing or incomparable evidence.

## When to use
Use `snapshot` to write a dated baseline, or `compare` to produce deltas and changes in a period. A snapshot may include an optional local run only after its L3 gate; it does not run tests by default. Do not use this skill to calculate percentiles/flakiness in the language model or to edit project configuration.

## Reads
Always read `.github/ai-qa/project/project.md` for CI, test landscape, components, environments and dependencies. Read `.github/ai-qa/project/conventions/testing.md` for `Scopes`, `Commands`, `Reports` and environments; `conventions/qa-process.md` for safe commands; `conventions/reporting.md` for reporting conventions; and `conventions/integrations.md` for configured CI operations. Read `.github/ai-qa/framework/method/{safety,discovery,artefacts,traceability,git}.md`, selected pack, static test/config files, existing coverage reports and fresh CI/run artefacts. If project files or prior baselines are missing, gather minimum read-only evidence and suggest `qa-configure`; never refuse solely because an upstream artefact is absent.

## Work-id
Resolve per `.github/ai-qa/framework/method/git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs
Take mode, test/repository scope, reference revision or dates, environment, optional CI-history depth, and whether a local test run is explicitly requested. For `compare`, identify the two dated snapshots or comparison period. Inspect current ref and dirty state without changing the user's work. Use `project.md` CI configuration and confirmed integration settings; if history is unavailable, record that rather than inferring it.

## Procedure
### Snapshot
1. Record date/time, source commit/ref, environment/config identity, requirement revision and FR/NFR/scenario scope. List exclusions, known failures, evidence age and data gaps.
2. Produce a static inventory of test paths/frameworks/levels and existing assertions, not filenames alone. Include coverage only when a coverage report already exists; record its format, path, revision and age. Do not run the suite unless explicitly requested.
3. Retrieve CI history through configured `ci.runs` for the project-defined or requested last N runs. Record run identifiers, SHA, start/time, duration, outcome and reruns on the same SHA when actually present. Use `ci.run.get` or `ci.test-results` only when details are needed. If the configured operation/transport is unavailable, record the failure and data gap; never assume CI history exists.
4. If a local run was requested, select the smallest documented test command from `conventions/testing.md` and follow `qa-run-tests` safety. Full, long or environment-dependent execution is L3 unless the exact command is marked safe in `qa-process.md`. Report unrun tests as `Not run`; missing prerequisites as `BLOCKED`.
5. Use counts only from structured CLI output or existing structured reports; state source and revision. Percentiles and flaky-test detection may be computed **only** by running `python3 tools/qa-stats.py` from the AI-QA framework checkout, with the user-supplied checkout path. Never run the helper from or install it into the target project. If the checkout/path or usable history is not supplied, report percentiles and flaky detection as **not computed**.
6. Present findings before writing. Write both `.github/ai-qa/baselines/<date>.md` and `.github/ai-qa/baselines/<date>.json` on a non-default branch. Show differences and obtain confirmation before replacing any existing dated baseline.

### Compare
1. Load the requested dated Markdown/JSON snapshots and validate source revisions, scopes, environment/config and report provenance. Mark missing, stale or unlike-for-like inputs explicitly; do not compare incomparable counts as deltas.
2. Report deltas and changes in the specified period in non-causal wording. Separate inventory/coverage changes, run outcomes/durations, same-SHA reruns, known failures and data gaps. Do not attribute a change to a code change without supporting evidence.
3. Recompute helper statistics only when the exact framework-checkout requirement and sufficient structured history are met; otherwise state `not computed`. Do not mutate historical snapshot files in compare mode.

## Output
`snapshot` writes `.github/ai-qa/baselines/<date>.md` and `.github/ai-qa/baselines/<date>.json`; `compare` returns a comparison report and, only when requested, records it in `qa-work/<work-id>/execution.md`. Update `qa-work/<work-id>/index.md` with snapshot links or comparison scope, source revisions, evidence, staleness, status and approval/gate log. Markdown front matter:

```yaml
---
work-id: "<work-id>"
skill: "qa-baseline"
framework-version: "<installed-version-or-unknown>"
created: "<UTC-ISO-8601>"
inputs:
	- source: "<repository/report/CI/snapshot path or link>"
		revision: "<commit/run ID/document revision/observed time>"
---
```

The JSON companion must be valid JSON and include equivalent provenance in a `metadata` object. Use this Markdown structure:

```markdown
## Scope and provenance
## Static inventory
## Existing coverage evidence
## Local run
## CI history
## Statistics
## Data gaps and comparability
## Drift
```

Report counts only with structured-source evidence. Statistics must explicitly say either the helper path/run and result or `Percentiles: not computed; flaky detection: not computed.` The index links both files; no raw credential-bearing logs are committed.

## Side effects and safety
| Action | Level | Gate |
|---|---:|---|
| Read repository, structured reports and CI via `ci.runs`/`ci.run.get`/`ci.test-results` | L0 | None |
| Write a dated baseline on a non-default branch | L1 | No separate gate; workflow plan approval first in orchestrated workflows |
| Run local/full/environment-dependent tests | L3 | Explicit approval unless the exact command is marked safe in `qa-process.md` |
| Run `qa-stats.py` from the supplied framework checkout | L0 | No install; path must be the framework checkout, not target project |
| Publish baseline externally or alter project configuration | L4/L5 | Not performed here; separate approval via owning skill |

Never checkout/reset branches, mutate shared test data, run destructive commands, change thresholds, write `.github/ai-qa/project/**`, or imply that an unexecuted suite passed. Baseline writes are AI-QA-owned data, not project adaptation-layer writes.

## Drift
If evidence contradicts project conventions or project.md, record it under Drift in the artefact and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
