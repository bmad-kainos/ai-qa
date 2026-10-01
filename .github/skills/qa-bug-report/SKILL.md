---
name: qa-bug-report
description: Draft an evidence-based defect report from reproduction steps or a failing test; hand off approved filing to qa-publish.
argument-hint: "[failure, reproduction or related ticket]"
user-invocable: true
---

# Report a bug

## 1. Trigger and scope
Invoke directly for an observed defect or failing test needing an actionable **draft**. A test failure alone is not proof of a product bug. Filing belongs to `qa-publish`.

## 2. Inputs
Gather actual and expected results (cite AC/spec or stable FR/NFR), steps, environment/build/commit, frequency, affected scope, supporting log or screenshot, related work ID/ticket and workaround. Ask for essential missing reproduction facts; mark nonessential fields **Unknown**. If `qa-work/<work-id>/index.md` exists, check source/run freshness before reusing failure analysis.

## 3. Context and prerequisites
Read `.github/ai-qa/framework/method/safety.md`, `discovery.md`, `failure-classes.md` and `artefacts.md`; `.github/ai-qa/project/project.md` and named `conventions/integrations.md`, `reporting.md` and `qa-process.md` if present, then other approved `conventions/*.md` (otherwise derive read-only session context), issue template, tracker conventions and available failure analysis. Use configured provider recipe to shape a tracker-ready draft only; deployment-specific fields/transport stay in recipes. Without integration, pasted evidence and manual Markdown suffice.

## 4. Procedure
1. Confirm reproducibility and distinguish product defect from stale expectation, flaky test, infrastructure, data or permissions issue; cross-check same-environment baseline and existing bugs to avoid duplicates. If classification is unknown, label **suspected** and request a focused diagnostic.
2. Assign justified severity (critical: data loss/security/core outage; high: blocking core path; medium: impaired with workaround; low: minor) separately from configured tracker priority. Do not infer business impact from stack trace alone.
3. Draft: concise summary; severity/rationale; environment/version/branch; linked ticket and FR/NFR; exact numbered reproducible steps with safe test data; expected versus actual with concrete values; frequency; impact; redacted evidence links; workaround. Include root cause or suggested fix **only if supported**.
4. If filing requested, show exact report, target project/work item type and proposed priority; hand off to `qa-publish` for independent L4 exact-content/destination approval, provider write and verification. If no tracker is configured, return copy-ready Markdown and state not filed.

## 5. Safety gates
No issue creation within this skill, fabricated logs/root cause, guessed ticket key or duplicate creation. A project key is an issue-ID prefix (PROJ in PROJ-123), never an access token. Redact PII, tokens and sensitive payloads; never execute destructive reproduction steps without approval.

## 6. Outputs and evidence
A requested saved report needs YAML frontmatter `work-id`, `skill: qa-bug-report`, `framework-version` (installed or `unknown`), `created` (UTC ISO) and `inputs` (failure/test/spec artefact paths/links with revisions). Standalone local index updates need no extra gate on a non-default branch; orchestrated writes follow L1 plan approval.

Return complete draft report, confidence/reproduction status, evidence provenance and unknowns; mark **DRAFT** or **BLOCKED**. Only `qa-publish` can report **FILED** with verified URL. If saving a report was explicitly approved, use `qa-work/<work-id>/outputs/` with frontmatter for work ID, skill, source/run revision, environment, generated time and evidence; update `index.md` without changing project configuration.

## 7. Standalone and handoff
Resolve work ID from explicit input, then a ticket key in the branch according to confirmed `.github/ai-qa/project/conventions/git.md` if present, else `adhoc-YYYYMMDD-<safe-slug>`; do not invent a real ticket. If prior failure analysis is absent, gather minimal expected/actual and steps. Recheck source/config/branch/run drift; recommend `qa-configure refresh` for project-layer changes, never change that layer here.

Derive context from supplied failure or repository if no earlier analysis exists. Suggest `qa-analyse-failure` if classification remains uncertain; reporting does not modify tests or code. Suggest `qa-publish` for the separately approved external write.
