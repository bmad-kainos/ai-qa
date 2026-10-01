# AI-QA

AI-QA v1 is a project-aware QA/QE framework for **GitHub Copilot in VS Code**. It installs Markdown agents, skills, instructions and framework references into a repository; it does not install an application runtime or test runner. The project runs its own tests. MCP is optional: every external operation has a manual fallback.

## Install

From a separate AI-QA checkout (do not install into this repository):

```sh
./install.sh install /path/to/project
./install.sh verify /path/to/project
```

On Windows, use `./install.ps1 install C:\path\to\project` (PowerShell). `--dry-run` previews changes. If existing `qa*` agents, skills or instructions collide, choose an explicit `--prefix <name>` or resolve the collision before installation. See [manual install](docs/manual-install.md) for a non-scripted option.

Open the project in VS Code and ask `qa-configure` to configure it. Inspect its discovered evidence and suggested decisions, approve the adaptation diff at L5, then ask `qa` for `design`, `automate`, `full`, `triage` or invoke any `qa-*` skill directly. `qa-configure refresh` reconciles changed project evidence while preserving user-managed sections.

```sh
./install.sh update /path/to/project
./install.sh verify /path/to/project
./install.sh uninstall /path/to/project
```

Updates preserve modified installed files and emit `.ai-qa-new` copies for review. Uninstall preserves project knowledge and baselines unless explicitly purged. Read [migrations](docs/migrations.md) before updating.

## Where information lives

| Path in target repository | Owner | Purpose |
|---|---|---|
| `.github/ai-qa/framework/` | AI-QA | Portable methods, defaults, provider recipes and test packs |
| `.github/agents/qa*.agent.md`, `.github/skills/qa-*/` | AI-QA | VS Code Copilot entry points |
| `.github/ai-qa/project/project.md` | Project | Sourced description of *what* this project is |
| `.github/ai-qa/project/conventions/*.md` | Project | *How* AI-QA works here, including providers, deployments and transports |
| `qa-work/<work-id>/index.md`, `outputs/` | Project | Committed traceability and deliverables |

The default `.gitignore` policy excludes intermediate work, logs and test data. Adapt it through `qa-configure` if the project has different retention rules. `qa` cannot change the project-owned layer. Never paste credentials into configuration; record environment variable **names** only.

## Safety and workflows

Read-only operations need no gate. Local edits are permitted only on non-default branches after workflow plan approval. Local branch creation and commits (L2), environment-dependent/full tests (L3 unless explicitly safe), external writes and pushes (L4), and installation of dependencies or project adaptation (L5) require explicit, action-specific approval. Branch creation does **not** imply a push; AI-QA never merges or modifies product code in its failure fix loop.

Workflows are resumable; non-stale artefacts are reused. `design` analyses a requirement, maps code and coverage, designs scenarios, assesses regression and automation, reviews design, then prepares a plan after approval. `automate` generates and checks tests against the project's framework and runs them subject to gates. `full` joins both; `triage` classifies failures and can prepare a bug report. See [walkthroughs](docs/walkthroughs.md).

## Development

Examples in `examples/fixtures/` exercise Java/Azure DevOps, TypeScript/GitHub, Python/Jira Cloud, .NET, an empty repository and conflicting conventions; `examples/expected/` illustrates sourced discovery and project context for each. The optional, standard-library-only `tools/qa-stats.py` runs from **this checkout**, not from a target project. It accepts a JSON array of `{ "sha", "outcome": "passed"|"failed", "duration_seconds" }` and returns structured percentiles, same-SHA reruns and flaky SHA evidence; without it, label those metrics *not computed*.

Methodology is informed by the Generic QA POC; pack and skill guidance adapts [Feabhas](https://github.com/bmad-kainos/feabhas) under its [MIT licence](docs/licenses/feabhas-MIT.txt). An AI-QA-specific licence and contribution policy are not declared here.
