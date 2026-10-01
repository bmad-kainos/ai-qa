---
work-id: "<ticket-or-feature-id>"
skill: "qa-workflow"
framework-version: "<installed-version-or-unknown>"
created: "<UTC-ISO-8601>"
inputs:
  - source: "<ticket-or-repository-path-or-link>"
    revision: "<commit-or-document-revision-or-observed-time>"
---

# QA Work Index

**Scope:** <ticket, feature or bounded investigation>
**Branch / revision:** <confirmed branch and commit>
**Workflow:** <design / automate / full / triage / independent skill>
**Updated:** <UTC timestamp>

## Workflow step status and staleness

Status values: Not started · In progress · Complete · Skipped · Blocked · Stale. A file's existence does not mean its step is complete. Stale means any input is newer or changed; unknown freshness is not current. Record skipped steps and their consequences.

| Workflow | Step | Status | Artefact | Inputs checked / latest revision | Staleness / note |
|---|---|---|---|---|---|
| design | Analyse requirement | Not started | `requirement.md` | <revision> | <fresh / stale / unknown> |
| design | Code context / branch verification | Not started | `context.md` | <revision> | <fresh / stale / unknown> |
| design | Requirement coverage gaps | Not started | `coverage.md` | <revision> | <fresh / stale / unknown> |
| design | Design manual scenarios | Not started | `design.md` | <revision> | <fresh / stale / unknown> |
| design | Regression risk | Not started | `regression.md` | <revision> | <fresh / stale / unknown> |
| design | Automation plan | Not started | `automation.md` | <revision> | <fresh / stale / unknown> |
| design | Design review | Not started | `review.md` | <revision> | <fresh / stale / unknown> |
| design | Final test plan | Not started | `outputs/test-plan.md` | <revision> | <fresh / stale / unknown> |
| automate | Generate tests | Not started | <test paths> | <revision> | <fresh / stale / unknown> |
| automate | Code review | Not started | `review.md` | <revision> | <fresh / stale / unknown> |
| automate | Run tests | Not started | `execution.md`, `logs/` | <run ID/commit/environment> | <fresh / stale / unknown> |
| automate | Analyse failures / fix loop | Not started | `execution.md` | <run IDs> | <fresh / stale / unknown> |
| automate | Update index and plan | Not started | `index.md`, `outputs/test-plan.md` | <revision> | <fresh / stale / unknown> |
| full | Design checkpoint / approval | Not started | Gate log | <approval scope/time> | <not applicable / pending> |
| triage | Failure analysis | Not started | `execution.md` | <run/log revision> | <fresh / stale / unknown> |
| triage | Bug report draft | Not started | `outputs/bug-*.md` | <evidence revision> | <fresh / stale / unknown> |
| triage | External publication | Not started | <provider receipt/link> | <exact destination/content> | <L4 gate state> |

## Traceability matrix

Keep stable `FR`/`NFR` IDs. Distinguish assessed, automated and deliberately not automated. Existing test evidence must identify relevant assertions, not only file existence. A result includes run, environment and time.

| FR/NFR | Existing evidence (test/assertion or gap) | Scenarios | Automation decision (assessed / automated / deliberately not automated, with reason) | Test files | Last result (run / environment / time) |
|---|---|---|---|---|---|
| FR1 | Not assessed | — | Assessment pending | — | Not run |

## QA Summary

| Ticket | Readiness | Max risk | Coverage verdict | Scenarios written/not written | Automated/manual/not needed | Run result | Published |
|---|---|---|---|---|---|---|---|
| <ticket or work ID> | <Green / Amber / Red> | <LOW / MEDIUM / HIGH / CRITICAL / Unknown> | <Pass / Needs Improvement / Insufficient / Not assessed> | <counts and IDs> | <decision and reason> | <PASS / FAIL / BLOCKED / Not run> | <destination and receipt / Not published> |

## Open questions

- <question, evidence and owner, or “None”>

## Gate log

| Gate | Action / target | Exact payload or command / side effects | Approver and time | Outcome / ID or URL |
|---|---|---|---|---|
| <workflow plan / design / L2–L5> | <action> | <exact approved scope> | <explicit affirmative, actor, time> | <result or pending> |