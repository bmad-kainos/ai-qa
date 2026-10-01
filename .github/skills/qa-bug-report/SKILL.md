---
name: qa-bug-report
description: Draft a complete, evidence-based bug report from reproducible unexpected behaviour; use when a defect needs documenting or filing.
argument-hint: "[failure, reproduction steps, error, or related work ID]"
---

# Bug report
Generate a well-structured, actionable bug report from reproduction steps, failing test output, or a plain-English description of unexpected behaviour. A test failure alone does not prove an application defect; classify it first when evidence is unclear.

## When to use
Use when a defect has been found during manual or automated testing, a confirmed application defect needs a tracker-ready report, or a user asks to raise/log a bug. If classification remains uncertain, use `qa-analyse-failure` first or clearly label the report suspected. Creating a work item is done only via `qa-publish` using `workitem.create` at L4; this skill does not call a provider directly.

## Reads
Always read `.github/ai-qa/project/project.md` for project summary, components, constraints, environments and dependencies; read `.github/ai-qa/project/conventions/qa-process.md` for evidence/reporting process, `conventions/integrations.md` for configured work-item provider and transport, and `conventions/reporting.md` for report formats. Read `.github/ai-qa/framework/method/{safety,discovery,failure-classes,artefacts,work-id-and-git}.md`, the applicable work-item template/provider guidance, and fresh `qa-work/<work-id>/` execution, failure analysis and index artefacts. If project files or prior analysis are missing, gather the minimum from supplied evidence and read-only repository context; never refuse solely because an artefact is absent.

## Work-id
Resolve per `.github/ai-qa/framework/method/work-id-and-git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs
Gather what went wrong; reproduction steps; expected behavior from the confirmed AC/spec/FR; actual behavior; environment/build/branch/commit; related ticket; supporting logs, screenshots or test output; frequency, impact and workaround. If anything is missing, gather the minimum from the run, source or user-provided evidence. Mark nonessential unknown fields `Unknown`; do not fabricate logs, identifiers, causes or impact. Confirm report and evidence freshness before reuse.

## Procedure
1. Confirm reproducibility where evidence permits. Distinguish an application defect from a test defect, stale expectation, flaky/nondeterministic behavior, environment/infra, test data, access or unknown using `failure-classes.md`. Cross-check a comparable baseline and available existing work items to avoid duplicates. If the classification is unknown, label it **suspected** and state the focused diagnostic that would decide it.
2. Assign **one** severity level using this rubric:

	| Severity | Criteria |
	|---|---|
	| **Critical** | System crash, data loss, security vulnerability, complete loss of core functionality |
	| **High** | Core feature broken, no workaround available, blocking testing progress |
	| **Medium** | Feature partially broken, workaround exists, or non-critical path affected |
	| **Low** | Minor cosmetic issue, edge case, or inconvenience with easy workaround |

	State a concise evidence-based justification. Keep severity separate from the configured tracker priority; do not infer business impact from a stack trace alone. Use project/provider priority options if configured; otherwise state `Not configured` rather than mapping severity to a priority.
3. Draft a concise summary; severity and justification; environment/version/branch; related ticket and FR/NFR; exact numbered reproducible steps using safe test data; expected versus actual with concrete values/statuses; frequency; impact; redacted evidence links; workaround. Include root cause or suggested fix **only if already supported by evidence**.
4. Use the following report template without changing its evidence meaning:

	```markdown
	## Summary
	<One sentence: what is broken and where>

	## Severity
	<Critical / High / Medium / Low> — <one-line evidence-based justification>

	## Environment
	- Environment: <configured environment or Unknown>
	- Branch / version: <branch, commit or version, or Unknown>
	- Related ticket: <confirmed work-item key or N/A>
	- Requirement: <FR/NFR/spec reference or Unknown>

	## Steps to Reproduce
	1. <First step>
	2. <Second step>
	3. <Third step — the one that triggers the bug>

	## Expected Behaviour
	<What should happen based on the ACs, spec, or requirements>

	## Actual Behaviour
	<What actually happened — be specific, include values, status codes, error messages>

	## Supporting Evidence
	<Paste redacted error message, stack trace, failing test output, screenshot/log link, or note "see attachment">

	## Root Cause (if known)
	<Optional — only include if the cause is already identified by evidence>

	## Suggested Fix (if known)
	<Optional — only include if a fix is obvious from the evidence>

	## Priority
	<Configured tracker priority, or Not configured; keep separate from severity>
	```

5. If filing is requested and a provider is configured, show the exact report, destination and work-item type, then hand off `workitem.create` to `qa-publish` for its independent L4 approval, provider write and verification. If no provider is configured, output Markdown only and state that it was not filed. Never report **FILED** without a verified receipt/URL from `qa-publish`.

## Output
Save the report to `qa-work/<work-id>/outputs/bug-<slug>.md`; update `qa-work/<work-id>/index.md` with status (`DRAFT`, `BLOCKED` or verified `FILED`), evidence links, source/run revision, reproduction and confidence, destination/approval outcome, and output path. Use front matter:

```yaml
---
work-id: "<work-id>"
skill: "qa-bug-report"
framework-version: "<installed-version-or-unknown>"
created: "<UTC-ISO-8601>"
inputs:
  - source: "<failure/test/spec/work artefact path or link>"
	 revision: "<run ID/SHA/document revision/observed time>"
---
```

The output is the report template above, plus a short confidence/reproduction status and evidence provenance. Redact PII, credentials, tokens and sensitive payloads. Do not overwrite a stale report silently.

## Side effects and safety
| Action | Level | Gate |
|---|---:|---|
| Read supplied/repository evidence and configured work-item data | L0 | None |
| Write bug Markdown and update the index on a non-default branch | L1 | No separate gate; workflow plan approval first in orchestrated workflows |
| Create a work item via `qa-publish` / `workitem.create` | L4 | Always preview exact destination and payload; explicit affirmative approval required |
| Attach/publish evidence or comment | L4 | Separate exact content/destination approval through `qa-publish` |

Do not execute destructive reproduction steps without approval, guess a ticket key, create duplicates, disclose secrets, or edit `.github/ai-qa/project/**`.

## Drift
If evidence contradicts project conventions or project.md, record it under Drift in the artefact and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
