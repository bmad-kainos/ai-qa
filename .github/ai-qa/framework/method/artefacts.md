# Work artefacts, index and freshness

L1 is **not an approval gate**: local artefact edits are allowed on a
non-default branch, and orchestrated workflow edits must follow approval
of that workflow plan. Standalone local documents require no separate L1
prompt. Summarise every change. Maintain one
`qa-work/<work-id>/index.md` per ticket, feature or bounded investigation;
the work ID is not necessarily an issue key. Never edit `.github/ai-qa/project/`
to create a work artefact: only Configure writes project configuration.

## Layout and default commit policy

```text
qa-work/<work-id>/
  index.md
  discovery.md
  requirement.md
  context.md
  coverage.md
  design.md
  regression.md
  automation.md
  review.md
  execution.md
  logs/
  outputs/
    test-plan.md
    comment.md
    bug.md
    test-data.sql
```

Resolve work ID using `git.md`: explicit user ID → confirmed branch ticket
matching the configured pattern → proposed `adhoc-YYYYMMDD-slug`.
Create only files relevant to this work item, not empty placeholders.
`index.md` links each produced artefact and its status. By default,
commit the reviewed `index.md` and non-sensitive approved deliverables
under `outputs/` **only after a separate L2 commit approval**. Keep
intermediate requirement/context/coverage/design/regression/automation/
review/execution drafts, `logs/`, raw test data, secret-bearing files
and generated reports out of commits by default; honour stricter
project retention/ignore rules. SQL test data is not automatically
safe merely because it is under `outputs/`: review schema, destination,
personal data and cleanup before including it in a deliverable or commit.
Never commit credentials, cookies, live identifiers or confidential logs.

## Per-artefact provenance and staleness

Every Markdown artefact, including `index.md` and deliverables, starts
with YAML frontmatter carrying these **required** fields:

```yaml
---
work-id: "<ticket-or-feature-id>"
skill: "<qa-skill-name>"
framework-version: "<installed-version-or-unknown>"
created: "<UTC-ISO-8601>"
inputs:
  - source: "<ticket-or-repository-path-or-link>"
    revision: "<commit-or-document-revision-or-observed-time>"
---
```

`inputs` lists **every** decision-relevant upstream source: ticket/AC
revision, branch/commit, project context and conventions, applicable
pack/version, earlier analysis artefacts and test-run IDs as appropriate.
Use a SQL comment header with the same keys for `test-data.sql` so the
file remains valid SQL; record each raw log's provenance in `execution.md`
and the index, not by modifying logs. Do not put secrets in metadata.

On resume, check the current revision/time of **each** listed input.
If **any input is newer or has changed** since the artefact was generated,
mark that artefact **stale** and refresh or explicitly defer it, then
check its downstream dependants. An unchanged file path does not prove
freshness; a source that cannot be checked is `?`, not “current”.
Reuse only non-stale work and preserve stable FR/NFR IDs across updates.
State source revision, environment, result provenance and uncertainty.

## Required index traceability

The index lists scope, source/branch revisions, readiness, approvals,
workflow-step status, artefact paths, open questions and a matrix:

| FR/NFR | Existing evidence (test/assertion or gap) | Scenarios | Decision | Test files | Last result (run/env/time) |
|---|---|---|---|---|---|
| FR1 | Not assessed | — | Assessment pending | — | Not run |

For every requirement distinguish **assessed**, **automated** and
**deliberately not automated** (with reason and owner), rather than
equating a suggested test with a written or passing test. Link scenario
IDs and the actual test path/assertion and run evidence, or label gaps.
The plan carries the eight-column QA Summary from
`ticket-to-test-plan.md`, all 13 regression areas, dedup decisions and
open questions. `PASS`, `FAIL`, `BLOCKED` and `Not run` require accurate
provenance; publication requires a receipt/link, not a draft file.

Record each action gate in the index:

| Gate | Action / target | Exact payload or command / side effects | Approver and time | Outcome / ID or URL |
|---|---|---|---|---|
| L2–L5 as applicable | — | — | — | — |

Workflow-plan and design-finalisation approvals should also be logged
with scope and time. For L2–L5 show action, target, exact payload and
side effects; ask; act only on an explicit affirmative answer; report
the resulting ID/URL or local outcome; then log it. L1 creates no
separate approval request. External publication always has its own L4
gate even when a matching `outputs/comment.md` or `outputs/bug.md` exists.
