# Changelog

All notable changes to AI-QA are recorded here. The installer prints the sections newer than the installed version during `update`.

## v1.0.0

First release of AI-QA for GitHub Copilot in VS Code.

- **Agents:** `qa` (router, workflows, index, safety) and `qa-configure` (discover → confirm → adapt, deployment identification, `refresh`).
- **Skills (21):**
  - Core: `qa-analyse-requirement` (single/batch/clarify), `qa-map-code` (+verify), `qa-coverage-gaps` (requirement/repo/`--inventory`), `qa-design-scenarios`, `qa-regression-risk`, `qa-automation-plan`, `qa-review-tests` (design/code), `qa-generate-tests` (+scaffold), `qa-run-tests`, `qa-analyse-failure` (bounded fix loop), `qa-test-plan` (ticket/sprint), `qa-publish`.
  - Supporting: `qa-bug-report`, `qa-ask-docs`, `qa-baseline`, `qa-retrospective`.
  - Engineering: `qa-create-branch`, `qa-create-pr`, `qa-tech-report`, `qa-update-docs`.
  - Discovery: `qa-discover`.
- **Workflows:** `design`, `automate`, `full`, `triage`. They are resumable and skippable and reuse non-stale artefacts.
- **Manual scenario format:** two formats, `bdd` (Given / When / Then, the default) and `steps` (numbered steps with expected results). `qa-configure` decides which during its Confirm step and records it in `conventions/qa-process.md`; `qa-design-scenarios`, `qa-test-plan`, `qa-review-tests` and `qa-publish` follow the setting.
- **Framework:**
  - Method files: discovery, safety (L0–L5), artefacts, traceability, dedup rule, scenario format, readiness, automation criteria, 13 regression areas, effort estimation, failure classes, precedence, clarifying questions, work-id and git rules, workflows.
  - Defaults: git, testing, qa-process, reporting.
  - Templates: project, discovery, conventions ×5, work-index, artefact, test-plan, qa-project instructions.
- **Project Context:** a sourced `project.md` (what the project is), kept separate from `conventions/*.md` (how AI-QA operates).
- **Providers:** an operations contract, plus Jira and Confluence (Cloud and Server/DC), Azure DevOps, Azure Wiki and GitHub. Transports are MCP, CLI, REST or Manual, and Manual is always available. Variants not tested against a live tenant are marked unverified.
- **Packs:**
  - Full tier: `playwright-ts`, `pytest`, `junit5-restassured`.
  - Conventions tier: `selenium-java`, `cucumber-java`, `cypress-ts`, `jest-vitest`.
- **Installers:**
  - Pure-bash `install.sh` and PowerShell `install.ps1` with identical behaviour.
  - Commands: `install`, `update`, `verify`, `uninstall`. Flags: `--dry-run`, `--prefix`, `--purge`.
  - Behaviour: SHA-256 manifest, marked blocks, `.ai-qa-new` on conflict, and a refusal to install into the AI-QA checkout itself.
- **Tooling:** the optional `tools/qa-stats.py`, standard library only, run from this checkout.
