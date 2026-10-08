# Migrations

## v1.1.0

Adds Jira/Confluence fallback script templates under `.github/ai-qa/framework/templates/atlassian-tools/`. Re-run `qa-configure refresh` to copy them to `qa-work/tools/atlassian/` if MCP is not used.

refresh-required: 1.1.0

## v1.0.0

Initial version; no previous framework manifests to migrate. After an update, review any `.ai-qa-new` conflicts before running `qa-configure refresh`. Framework updates do not migrate or overwrite `.github/ai-qa/project/` or baselines. Compare changed methods or packs to the project's rendered instructions; refresh is the only writer of project-owned adaptations.

To flag a framework release that requires adaptation refresh, add a standalone `refresh-required: <version>` line for each applicable version. The installer prints `This update requires qa-configure refresh` when that version falls between the installed and new framework versions.

## Numbered artefact names

`qa-work/<work-id>/` artefacts are now numbered in reading order: `01_requirement_analysis.md`, `02_code_context.md`, `03_coverage_assessment.md`, `04_test_scenarios.md`, `05_regression_risk.md`, `06_automation_plan.md`, `07_design_review.md`, `outputs/08_test_plan.md`, `09_execution.md`, `10_test_generation.md` and `11_code_review.md` (automate workflow). `index.md` is unchanged. Legacy names (`requirement.md`, `context.md`, `coverage.md`, `design.md`, `regression.md`, `automation.md`, `review.md`, `execution.md`, `outputs/test-plan.md`) are still read as a fallback; new files are always written with the new names and nothing is renamed silently. Rename existing folders yourself if you want them consistent. `index.md` and the test plan now start with a TL;DR and numbered Next Steps.
