# AI-QA flows

Mermaid diagrams for how AI-QA is installed, configured and used, and which files change at each stage.

| Diagram | Covers |
|---|---|
| [01-install.md](01-install.md) | Install, update, verify, uninstall |
| [02-configure.md](02-configure.md) | `@qa-configure`: discover → confirm → adapt, refresh, and what it reads and writes |
| [03-usage.md](03-usage.md) | `@qa` routing, the four workflows, and the provider/transport layer |
| [04-file-lifecycle.md](04-file-lifecycle.md) | Which files are created, changed, removed or kept at each stage |

The same flow in prose: [README](../../README.md) (install), the [user guide](../user-guide.md) (workflows, gates, artefacts) and the `qa-configure` agent file (11 steps).

## What changes in the target project

| Stage | Created | Modified | Removed | Left untouched |
|---|---|---|---|---|
| **install** | `.github/agents/qa*.agent.md` (2), `.github/skills/qa-*/` (21 folders), `.github/ai-qa/framework/**`, `.github/ai-qa/manifest.json` | Marked block in `.github/copilot-instructions.md` and `.gitignore`; either file is created if absent | Nothing | All project code, tests, CI, docs and other `.github` content |
| **configure** | `.github/ai-qa/project/project.md`, `discovery.md`, `conventions/{git,testing,qa-process,integrations,reporting}.md`, `.github/instructions/qa-project.instructions.md`, `.github/instructions/qa-<pack>.instructions.md`, `.vscode/mcp.json` (only if MCP chosen), `qa-work/tools/atlassian/*` (only if Jira/Confluence MCP was rejected; project-owned, never overwritten) | The same files on refresh (managed sections only) | Nothing | Framework files, code, tests, dependency manifests |
| **use** | `qa-work/<id>/**`, `.github/ai-qa/baselines/*`, new test files, local branches (L2) | Test files created in this work item, docs (`qa-update-docs`) | Nothing. Tests are never deleted, skipped or disabled | Product code is never changed by the fix loop; the default branch is never edited; nothing is merged |
| **update** | New framework files, `<file>.ai-qa-new` for files you edited | Unedited framework files, manifest, marked blocks | Framework files dropped from the release, if unedited | Project layer, baselines, qa-work, edited files |
| **uninstall** | Nothing | `copilot-instructions.md` and `.gitignore` (block removed, byte-for-byte restore) | Unedited installed files, manifest, empty dirs it created; the two files above only if AI-QA created them and they are now empty | Edited framework files (listed), project layer, baselines, `qa-work`. With `--purge` and confirmation, these three are deleted too |

## Terms

- **Provider recipe:** the per-system instructions in `framework/providers/<provider>.md`. For each operation, such as "get a work item" or "publish a page", a recipe gives:
  - the MCP tool names to look for;
  - the CLI command (`gh`, `az`);
  - a `curl` / `Invoke-RestMethod` call that reads tokens from environment variables;
  - a manual fallback.

  It also covers Cloud vs Server/DC differences and format conversion (for example Markdown → Confluence storage format). Recipes are documentation the agent follows, not code. The one exception is the optional Jira/Confluence fallback scripts in `framework/templates/atlassian-tools/`, which `qa-configure` can copy into `qa-work/tools/atlassian/` (L5) when MCP is not used. AI-QA ships no other client code.
- **Transport:** how an operation reaches the external system: MCP, CLI, REST, or Manual (copy-paste). `conventions/integrations.md` sets the preferred order, and Manual always works.
- **Project layer:** the files under `.github/ai-qa/project/`, plus the rendered instruction files. Only `qa-configure` writes them.
- **Gate:** a stop where the agent shows the exact action and payload and waits for an explicit "yes".
