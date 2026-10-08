# Work artefacts, index and freshness

Maintain one `qa-work/<work-id>/index.md` per ticket, feature or bounded investigation; a work ID is not necessarily an issue key. L1 local artefact edits are allowed only on a non-default branch; orchestrated workflow edits follow workflow-plan approval, while standalone local documents require no separate L1 prompt. Summarise every change. Never edit `.github/ai-qa/project/` to create a work artefact: only Configure writes project configuration.

## Layout

```text
qa-work/<work-id>/
  index.md
  01_requirement_analysis.md
  02_code_context.md
  03_coverage_assessment.md
  04_test_scenarios.md
  05_regression_risk.md
  06_automation_plan.md
  07_design_review.md
  09_execution.md
  10_test_generation.md   # automate workflow
  11_code_review.md       # automate workflow
  logs/
  outputs/
    08_test_plan.md
    comment.md
    bug-*.md
    test-data.*
```

Numbers give reading order; gaps are allowed when a step is skipped. Create only files relevant to this work item, not empty placeholders. `index.md` links each produced artefact and records its status and staleness.

## Legacy filenames

Always write the numbered names. When a numbered file is absent, read the legacy name as a fallback: `requirement.md`, `context.md`, `coverage.md`, `design.md`, `regression.md`, `automation.md` (plan or generation record), `review.md` (design or code review; decide from its `skill`/mode front matter and content), `outputs/test-plan.md`. `execution.md` is the legacy name of `09_execution.md`. Never silently rename or delete a legacy file: report it, write the new file, and let the user migrate (see `docs/migrations.md`). If both exist, the numbered file wins; note the legacy file in the index.

## Gap markers

Use these markers for missing or unrun information: `Not provided` (required input missing), `Unknown` (optional value missing), `Not assessed` (area not analysed), `Not run` (no execution evidence), `Not published` (nothing posted externally), and `Not configured` (project setting absent). These are gap markers, not workflow statuses or result values: use the required status/result vocabulary where specified, including `Blocked` and `PASS` / `FAIL` / `BLOCKED` / `Not run` with provenance. Do not use `N/A` or `NOT FOUND` as generic gap markers; `qa-ask-docs` states a documentation gap as `Not documented` with `Scope searched`. `qa-retrospective` and `qa-tech-report` keep `not available` / `not computed` for now (wording decision pending). This complements the `Not provided` rule in `clarifying-questions.md`.

## Commit and ignore defaults

By default, commit `qa-work/<work-id>/index.md` and `qa-work/<work-id>/outputs/`; ignore everything else, including intermediate artefacts and `logs/`. Projects can change this policy in `.github/ai-qa/project/conventions/qa-process.md` under `qa-work policy`. Honour a confirmed project policy. Never commit credentials, cookies, personal data, raw logs, live identifiers or confidential payloads. Test-data files in outputs still require data/safety review.

## Per-artefact front-matter

Every Markdown artefact, including `index.md` and outputs, starts with YAML front-matter carrying these required fields:

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

`inputs` lists every decision-relevant upstream source: ticket/AC revision, branch/commit, project context and conventions, applicable pack/version, earlier analysis artefacts and test-run IDs as appropriate. Do not put secrets in metadata. For non-Markdown outputs use a suitable metadata comment/header when the format supports it; log raw-log provenance in `09_execution.md` and the index, not by modifying logs.

After the front-matter, every skill-produced artefact except `index.md` and `outputs/08_test_plan.md` opens with a header of two lines before any other section (those two open with the title and TL;DR instead, see below; the TL;DR verdict and next action serve as Result and Do next): **Result:** one-sentence verdict or outcome, and **Do next:** at most 3 ordered actions (or "None"). Details follow below it.

Start each skill-produced artefact from `.github/ai-qa/framework/templates/artefact.md`. It provides this front-matter, a scope and status line, a skill-specific output section and the **Drift** section that every skill must include. Start `index.md` from `templates/work-index.md` instead.

## TL;DR and Next Steps

`index.md` and `outputs/08_test_plan.md` open, directly after the title, with a **TL;DR** block (verdict, top 3 risks, single next action) followed by a numbered **Next Steps** section. Each Next Steps row has: action, owner, evidence (FR/NFR/scenario ID) and blocker flag (Yes/No). Order: blockers first, then risk tier (CRITICAL to LOW), then effort (low first). `qa-test-plan` assembles it from the earlier artefacts' **Do next** lines, findings and gaps, de-duplicated, citing the source file number (e.g. `[03]`). Print TL;DR and Next Steps in chat before the QA Summary table.

## Staleness

An artefact is **stale if any input is newer or has changed** since the artefact was generated. On resume, check the current revision/time of every listed input. Mark the artefact stale and refresh or explicitly defer it, then check downstream dependants. An unchanged file path does not prove freshness; a source that cannot be checked is `?`, not current. Reuse only non-stale work and preserve stable FR/NFR IDs across updates. State source revision, environment, result provenance and uncertainty.

## Index contents and traceability

The index contains work ID and scope, step status and staleness, source/branch revisions, links to artefacts, readiness, open questions, the traceability matrix and gate log. For every requirement distinguish **assessed**, **automated** and **deliberately not automated** (with reason and owner). Link scenario IDs, actual test path/assertion and run evidence, or label gaps.

| FR/NFR | Existing evidence (test/assertion or gap) | Scenarios | Automation decision (assessed / automated / deliberately not automated, with reason) | Test files | Last result (run / environment / time) |
|---|---|---|---|---|---|
| FR1 | Not assessed | — | Assessment pending | — | Not run |

The QA Summary uses: **Ticket · Readiness · Max risk · Coverage verdict · Scenarios written/not written · Automated/manual/not needed · Run result · Published**. Include the 13 regression areas, dedup decisions and open questions in the test plan. `PASS`, `FAIL`, `BLOCKED` and `Not run` require accurate provenance; Published requires a receipt/link, not a draft file.

## Gate log

Record each gate, workflow-plan approval and design-finalisation approval in the index:

| Gate | Action / target | Exact payload or command / side effects | Approver and time | Outcome / ID or URL |
|---|---|---|---|---|
| L2–L5 / workflow plan / design approval as applicable | — | — | — | — |

For L2–L5 show action, target, exact payload and side effects; ask; act only on an explicit affirmative answer; report the resulting ID/URL or local outcome; then log it. L1 creates no separate approval request. External publication always has its own L4 gate even when a matching output file exists.

## Baselines

Baseline snapshots are stored at `.github/ai-qa/baselines/<date>.md` and `.github/ai-qa/baselines/<date>.json`. The optional baseline helper runs from the framework checkout only; it is not installed into or required by a target project.
