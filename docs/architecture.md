# Architecture

AI-QA is Markdown and configuration only. A target repository gains no runtime dependency, binary, discovery engine or REST client. The LLM reasons, but it follows fixed procedures in framework method files. The project's own tooling runs tests, and external systems are reached through configured transports.

For how it is installed, configured and used, see the [flow diagrams](flows/README.md).

## Layers

| Layer | Path in target | Owner | Writer |
|---|---|---|---|
| Entry points | `.github/agents/qa.agent.md`, `qa-configure.agent.md`, `.github/skills/qa-*/` | Framework | Installer |
| Framework | `.github/ai-qa/framework/{method,providers,packs,defaults,templates}/` | Framework | Installer |
| Project Context | `.github/ai-qa/project/project.md`, `discovery.md` | Project | `qa-configure` only (L5) |
| Conventions | `.github/ai-qa/project/conventions/{git,testing,qa-process,integrations,reporting}.md` | Project | `qa-configure` only (L5) |
| Rendered instructions | `.github/instructions/qa-project.instructions.md`, `qa-<pack>.instructions.md` | Project | `qa-configure` only (L5) |
| MCP config | `.vscode/mcp.json` (only if MCP chosen) | Project | `qa-configure` only (L5) |
| Artefacts | `qa-work/<work-id>/` | Project | `qa` and skills (L1) |
| Baselines | `.github/ai-qa/baselines/<date>.md\|.json` | Project | `qa-baseline` (L1) |

`project.md` describes **what** the project is: components, stack, environments, dependencies, CI/CD, test landscape, constraints and documentation sources. Each section carries a confidence level and source links. `conventions/*.md` describe **how** AI-QA operates on the project. The two are kept strictly separate.

Precedence: user instruction > project conventions > neighbouring code > pack > framework defaults. Safety gates sit outside this order and no instruction can relax them.

## Baseline statistics

`tools/qa-stats.py` is optional and uses only the Python standard library. It runs from the AI-QA checkout and is never installed. Percentiles and flaky-SHA detection come only from this tool. Without it, `qa-baseline` reports them as *not computed*, and the LLM never calculates percentiles.

## Out of scope for v1

- Binaries, discovery or transport code.
- Zephyr and Azure Test Plans.
- Monorepo overlays (v1 configures a single scope path).
- More full packs.
- GitLab and Jenkins.
- Planner and implementor packs.
- A commit-message skill.
- Dashboards.
- Hosts other than VS Code.
- Org-level install.
- Signed releases.
- AI test markers.
