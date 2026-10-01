---
name: qa-generate-tests
description: Generate maintainable automated tests from requirements, risk and existing project conventions; use for new or missing unit, integration, API or end-to-end coverage.
argument-hint: "[ticket, requirement, endpoint or code area]"
user-invocable: true
---

# Generate automated tests

## 1. Trigger and scope

Invoke directly for a ticket, acceptance criterion (AC), endpoint, feature or coverage gap. Generate only work-item-owned tests, not production changes or tracker records. Accept an approved design **or** derive scenarios from a supplied contract; no upstream skill is mandatory.

## 2. Inputs
- Take ticket/spec text, feature/endpoint, code area, chosen test branch, constraints and expected outcomes; use the configured provider or pasted data without requiring Jira.
- Identify stable `FR`/`NFR` IDs, affected implementation and risk. Reuse current approved design/coverage assessment when available; otherwise derive a scoped inventory. Ask for missing expected behaviour rather than guessing.
- If a `qa-work/<work-id>/index.md` exists, compare ticket revision, branch/commit and conventions before trusting it. Work ID may be a feature name rather than a fabricated ticket number.

## 3. Context and prerequisites
Read `.github/ai-qa/framework/method/safety.md`, `discovery.md`, `automation-criteria.md` and `artefacts.md`; `.github/ai-qa/project/project.md` and named `conventions/testing.md`, `qa-process.md`, `integrations.md` and `git.md` if present, then other approved `conventions/*.md`; the selected `.github/ai-qa/framework/packs/` pack; existing tests/fixtures and repository instructions. If project context is absent, derive read-only session context; only `qa-configure` may write the project layer. Discover actual runner, paths, language, auth and fixture conventions. First-class API guidance exists for Playwright/pytest plus the API contract pack; other packs provide conventions, not a guaranteed runnable harness. If no pack matches, use observed project idioms or ask for framework. Read provider recipes only when an integration is needed; never embed deployment instructions here.

## 4. Procedure
1. Map ACs/FRs/NFRs to actual existing assertions and identify gaps. Separate pure logic (unit), one boundary/request (integration/API) and multi-step journeys (E2E); do not claim coverage merely from filenames.
2. Prioritise meaningful happy, negative, boundary, error, auth/permission, feature-flag and regression scenarios by actual risk. For a REST endpoint with a documented contract, inventory at least a valid request, missing required field, invalid field type, unauthenticated request when auth applies, and two boundary cases for each constrained field; also check min, max, a valid middle and an invalid value where defined. Assert the documented status **and** error-body shape, never assume universal 400/422 responses. Mark non-applicable or unknown cases with a reason rather than inventing expected behaviour. Do not duplicate tests that already prove the same behaviour.
3. Present a traceability inventory (`requirement | level | case | expected assertion | reason/not written`) and intended file paths. State assumptions and omissions. Verify a non-default branch. Standalone requested local edits need no additional L1 gate; within `design/automate/full` obtain orchestrated L1 plan approval first.
4. Add only work-item-owned tests in the project's naming, assertion, parametrisation and fixture style. Use isolated, deterministic data and cleanup; verify both status and response contract for error paths when applicable. Do not encode real secrets or live customer data.
5. Run the smallest documented targeted static check/build/test **only when authorised and safe**. Record command, environment, exit status and failures; distinguish generated, compiled, executed and passed. Follow `qa-run-tests` L3 gate for full/environment-dependent runs. Recheck ticket and branch freshness before finalising.

## 5. Safety gates
Never alter product code, disable assertions or tests, or claim coverage based on filenames alone. Standalone scoped local test edits on a non-default branch are ungated, but orchestrated workflows require **L1** plan approval. **L5** dependency installation, **L3** full/environment-dependent runs and **L4** external writes require action-specific approval. Never perform destructive setup. Missing access or unsafe prerequisites means produce the test design and blockers, not an invented green run.

## 6. Outputs and evidence
For each requested saved artefact, include YAML frontmatter fields `work-id`, `skill: qa-generate-tests`, `framework-version` (installed version or `unknown`), `created` (UTC ISO timestamp) and `inputs` (source artefact paths/links and revisions). Standalone local index updates need no extra gate; orchestrated writes follow prior L1 plan approval.

Return changed file paths, requirement-to-test mapping, omissions and residual gaps, level and rationale, exact validation result, commit/branch/environment, provenance and blockers. Label generated but unexecuted tests **Not run**. If the user approved a durable output, update `qa-work/<work-id>/index.md` and a report under `outputs/` with frontmatter identifying work ID, skill, source revision, branch/commit, timestamp, evidence and approvals. Do not change the project layer. Mark stale earlier output for review rather than overwriting it.

## 7. Standalone and handoff
Resolve work ID in order: explicit ID; ticket key on the current branch following confirmed `.github/ai-qa/project/conventions/git.md` if present; otherwise `adhoc-YYYYMMDD-<safe-slug>`. Never pretend the fallback is a ticket. Missing optional prior artefacts are gathered from the smallest available source instead of blocking; on source/config/branch drift refresh only affected steps and suggest `qa-configure refresh` for project-layer changes—never edit that layer here.

When called alone, perform steps 2–6 from supplied/repository context without requiring another skill's output. Offer `qa-run-tests` for execution and `qa-analyse-failure` for real failures; no implicit publishing, commit or PR.
