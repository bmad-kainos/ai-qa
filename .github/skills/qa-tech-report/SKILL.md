---
name: qa-tech-report
description: Produce an evidence-based engineering/QA update for a specific date range from live git history and verified test results.
argument-hint: "[date range, scope and concise/standard/detailed/business format]"
user-invocable: true
---

# Technical report

## 1. Trigger and scope
Invoke directly for a weekly update, sprint technical summary or "what shipped" report. Reporting is not release approval or automatic publication. Works without a ticket or earlier QA workflow.

## 2. Inputs
Get requested date range (default: last seven calendar days ending today), ref/branch, work ID if relevant, audience and mode (`concise` default; standard/detailed/business when requested). Resolve relative dates to exact calendar bounds and state timezone. Request missing non-default scope rather than silently widening it. A work ID is not assumed to be a Jira key.

## 3. Context and prerequisites
Read `.github/ai-qa/framework/method/safety.md`, `discovery.md` and `artefacts.md`; `.github/ai-qa/project/project.md` and named `conventions/reporting.md`, `git.md` and `integrations.md` if present, then other approved `conventions/*.md` (otherwise derive read-only session context), plus actual report format rules. Query **live git history** for the requested range/ref before writing claims, excluding merge commits. Use configured providers for optional PR/work-item evidence; no Jira/Slack dependency by default. If `qa-work/<work-id>/index.md` exists, verify ticket/config/commit freshness before quoting it. A commit alone is not evidence of deployment or passing QA.

## 4. Procedure
1. Run `git log --since=<start> --until=<end> --no-merges --format=<hash,date,author,subject>` against the confirmed ref, using date/time bounds that include the user's intended end day. Record command/ref/timezone/range. If there are **no commits**, report the exact period and “No commits were made during this period.” and stop—never substitute older work or inferred delivery.
2. Group supported changes by capability/fix/test/docs/risk, verify claims against commit details/PR and associated evidence, and note non-conventional subjects as untyped rather than inventing a type. Distinguish authored, merged, released and deployed states; explicitly flag evidenced breaking/security changes.
3. Choose concise by default, or standard/detailed/business when requested; use audience-appropriate, jargon-light language and project format conventions. For a specifically requested weekly update, after the nonempty git log, use configured provider `workitem.search` (bounded, read-only) for current in-progress items to support "next week"; without an available provider label that portion unavailable rather than inventing commitments.
4. Attach **verified** QA outcomes, outstanding failures/blockers and next actions; label test evidence **Not available** if uninspected. Recheck git head before output and mark report stale/regenerate if commits changed during drafting.

## 5. Safety gates
Do not invent releases, delivery dates, test metrics, Jira status or "next week" commitments. Never publish to a wiki/tracker without showing the exact draft and obtaining independent **L4** approval. Avoid sensitive content from commits/logs.

## 6. Outputs and evidence
Requested saved reports need YAML frontmatter `work-id`, `skill: qa-tech-report`, `framework-version` (installed or `unknown`), `created` (UTC ISO) and `inputs` (git range/ref and referenced artefact revisions). The no-commits hard stop takes precedence over file creation or provider lookup.

Provide dated period/ref, mode, grouped achievements, QA evidence, risks, unknowns and commit/PR links or hashes. For an empty period state only period and no-commits result. If a file was requested, save in `qa-work/<work-id>/outputs/` or configured output path with frontmatter and index link (standalone: no extra gate; orchestrated: approved L1 plan). Mark superseded reports on drift; resolve an ad hoc ID instead of inventing a ticket.

## 7. Standalone and handoff
Resolve work ID from explicit ID, branch ticket according to confirmed `.github/ai-qa/project/conventions/git.md` if present, else `adhoc-YYYYMMDD-<safe-slug>` (not an issue key). Gather git range/ref without requiring a prior QA artefact. On history/config/branch drift rerun git log; recommend `qa-configure refresh` for project-layer changes without editing it.

Use live repository data without relying on previous sessions. Offer `qa-publish` for reviewed distribution, never post automatically.
