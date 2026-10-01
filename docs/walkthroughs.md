# Walkthroughs

## A new ticket (design)

In a configured project, ask `qa` to design a named ticket. `qa-analyse-requirement` fetches the work item via the configured provider/transport or requests pasted content. It assigns FR/NFR IDs, scores readiness and stops a Red workflow for refinement. `qa-code-context`, `qa-coverage-gaps`, `qa-design-tests`, `qa-regression-risk`, `qa-automation-plan` and `qa-review-tests` update `qa-work/<id>/index.md`. Approve the design before finalising the `qa-test-plan` output. `qa` shows the QA Summary in chat. Publishing is a separate L4 request through `qa-publish`.

## Automate and triage

Ask `qa` to automate an approved design, or pass a spec/scenarios directly to `qa-generate-tests`. Confirm the local branch gate separately from any push. Review the inventory before test generation; use the project's configured compiler/linter. Gate a full run if it is not marked safe. `qa-analyse-failure` documents evidence and confidence, fixes only work-item-owned test defects up to three iterations, and never changes product code. For an application defect, `qa-bug-report` prepares Markdown; creation via `qa-publish` is another L4 gate.

## Independent investigations

Invoke `qa-regression-risk` for an independent 13-area assessment, `qa-code-context verify <branch>` for FR status, `qa-coverage-gaps --inventory` for a read-only inventory, `qa-baseline snapshot` for a sourced baseline, or `qa-tech-report weekly` for non-merge commit reporting. Missing provider access falls back to pasted data/manual output. Do not claim unavailable CI, docs or work items were checked.

## Fixture walkthroughs

- `examples/fixtures/java-ado`: recognise Gradle/JUnit 5/RestAssured and Azure Pipelines/Boards evidence; verify local commands using help/list only.
- `examples/fixtures/typescript-github`: detect Playwright and GitHub Actions/PR template.
- `examples/fixtures/python-jira-cloud`: infer Jira Cloud from an `atlassian.net` URL and confirm deployment using a read-only probe when available.
- `examples/fixtures/dotnet`: identify solution and TRX-capable test command without installing Python.
- `examples/fixtures/empty`: record ∅ evidence and establish dated ★ defaults with approval.
- `examples/fixtures/conflicting`: show both contradictory Jira URLs and test commands as ⚠, then ask one evidence-based question at a time.

On each fixture, preview install/update/verify/uninstall in a *copy*, including a hand-modified framework file. Do not treat the fixtures themselves as configured projects or install the framework into this checkout.
The paired [expected discovery and project-context reports](../examples/expected/) show sourced observations, inferences, conflicts and unknowns for all six fixtures. They are examples, not cached outputs from a configured target, and must be refreshed against the actual checkout.
