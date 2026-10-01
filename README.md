# AI-QA

AI-QA v1 is a project-aware QA/QE framework for **GitHub Copilot in VS Code**. It installs Markdown agents, skills and framework references into a repository. It doesn't install an application runtime, a test runner, a binary or a client library. The project's own tooling runs its tests. MCP is optional: every external operation has a manual fallback.

```text
INSTALL → CONFIGURE (DISCOVER → CONFIRM → ADAPT) → USE → REFRESH
```

## Install

Run the installer from a separate AI-QA checkout. Don't install into this repository; the installer refuses to.

```sh
./install.sh install /path/to/project      # or: ./install.sh install --dry-run /path/to/project
./install.sh verify  /path/to/project
```

On Windows, use `./install.ps1 install C:\path\to\project` (PowerShell 5.1+ or 7). Both installers behave the same and use only shell built-ins and standard OS tools. If existing `qa*` agents, skills or instructions collide, the installer stops. You can then pick a namespace with `--prefix <name>` or resolve the collision first. See [manual install](docs/manual-install.md) for a non-scripted option.

```sh
./install.sh update    /path/to/project    # modified files are kept; new versions are written as <file>.ai-qa-new
./install.sh uninstall /path/to/project    # keeps project layer, baselines and qa-work unless --purge (confirmed)
```

Read [migrations](docs/migrations.md) before updating.

## Use

1. Open the project in VS Code and ask **`@qa-configure`** to configure it. It discovers evidence, asks one question at a time, only about real conflicts or unknowns, and shows the exact diff. Nothing is written until you approve the L5 gate.
2. Ask **`@qa`** for a workflow (`design`, `automate`, `full`, `triage`), or invoke any of the 21 `qa-*` skills directly.
3. Run `@qa-configure refresh` after the project changes or after a framework update that flags a refresh. Refresh never rewrites `<!-- ai-qa:user -->` sections.

| Group | Skills |
|---|---|
| Core | `qa-analyse-requirement` · `qa-code-context` · `qa-coverage-gaps` · `qa-design-tests` · `qa-regression-risk` · `qa-automation-plan` · `qa-review-tests` · `qa-generate-tests` · `qa-run-tests` · `qa-analyse-failure` · `qa-test-plan` · `qa-publish` |
| Supporting | `qa-bug-report` · `qa-analyse-docs` · `qa-baseline` · `qa-retrospective` |
| Engineering | `qa-branch` · `qa-create-pr` · `qa-tech-report` · `qa-update-docs` |
| Discovery | `qa-discover` |

See the [user guide](docs/user-guide.md) for workflows and walkthroughs.

## Where information lives

| Path in target repository | Owner | Purpose |
|---|---|---|
| `.github/agents/qa*.agent.md`, `.github/skills/qa-*/` | AI-QA | VS Code Copilot entry points |
| `.github/ai-qa/framework/` | AI-QA | Methods, providers, packs, defaults and templates; never edited per project |
| `.github/ai-qa/project/project.md` | Project (`qa-configure`) | *What* the project is: the sourced Project Context |
| `.github/ai-qa/project/conventions/*.md` | Project (`qa-configure`) | *How* AI-QA works here: git, testing, qa-process, integrations, reporting |
| `.github/instructions/qa-*.instructions.md` | Project (`qa-configure`) | Rendered project and pack instructions, scoped by `applyTo` to discovered test paths |
| `qa-work/<work-id>/` | Project | `index.md` and `outputs/` committed by default; working artefacts ignored |
| `.github/ai-qa/baselines/` | Project | Baseline snapshots |

Never put credentials in configuration. Record environment-variable **names** only.

## Safety

Safety gates are authoritative, and agent tool lists are not a safety mechanism. See [safety](docs/safety.md).

| Level | Covers | Gate |
|---|---|---|
| L0 | Reads and read-only probes | None |
| L1 | Local edits on a non-default branch | No gate; in workflows only after plan approval; always summarised |
| L2 | Create local branch, commit | Gated |
| L3 | Full / environment-dependent / long test runs | Gated unless marked safe in `qa-process.md` |
| L4 | Push, PR, comments, work items, publishing | Always gated |
| L5 | Dependency install, adaptation-layer writes, `mcp.json` | Always gated |

AI-QA never edits the default branch. Creating a branch never pushes it, and AI-QA never merges. The failure fix loop never touches product code.

## Repository layout

| Path | Purpose |
|---|---|
| `.github/` | The framework itself: `agents/`, `skills/` and `ai-qa/framework/`. These are the only files the installer copies into a project. VS Code also loads them in this repo, so you can try changes in place |
| `install.sh`, `install.ps1`, `VERSION`, `CHANGELOG.md` | Installers and release metadata |
| `docs/` | [Flows and diagrams](docs/flows/README.md), [architecture](docs/architecture.md), [user guide](docs/user-guide.md), [configure](docs/configure.md), [safety](docs/safety.md), [adding a pack](docs/adding-a-pack.md), [adding a provider](docs/adding-a-provider.md), [migrations](docs/migrations.md), [manual install](docs/manual-install.md) |
| `tools/qa-stats.py` | Optional standard-library helper for baseline percentiles and flaky-SHA detection. It runs from this checkout only and is never installed |
| `reference/zephyr/` | Zephyr knowledge kept for future work; not installed |
| `tests/` | Installer and `qa-stats` tests (`python3 -m unittest discover -s tests`) |

## Provenance

The methodology is ported from the Generic QA POC (`sylwia-luczak/AI-QA-AGENT_GENERIC@ac750bb`). The tooling, packs and engineering skills are adapted from Feabhas (`bmad-kainos/feabhas@b788dc1`) under its MIT licence ([notice](.github/ai-qa/framework/LICENSE-feabhas.txt), also installed with the framework). AI-QA itself is released under the [MIT licence](LICENSE).
