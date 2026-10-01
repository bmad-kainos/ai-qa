# Integrations and transports

> Generic source template. Only Configure, following an approved L5 adaptation,
> renders this to `.github/ai-qa/project/conventions/integrations.md`.

<!-- ai-qa:managed:start -->
| Field | Project value | Confidence / source link and revision |
|---|---|---|
| Work-item provider and project/repository identifier | ∅ unknown | ∅ |
| Jira issue key prefix (e.g. `PROJ` in `PROJ-1234`) | ∅ unknown | ∅ |
| Public Jira/ADO/GitHub base URL | ∅ unknown | ∅ |
| Confluence/Wiki space and page policy | ∅ unknown | ∅ |
| Provider operation and actual installed transport (MCP/CLI/API/manual) | ∅ unknown | ∅ |
| Read-only access probe and fallback to supplied/manual content | ∅ unknown | ∅ |
| External write scopes and approved destination policy | ∅ unknown | ∅ |
| Auth **environment variable names** and approved secret store | ∅ unknown | ∅ |
| Optional MCP endpoint/configuration, if explicitly approved | ∅ unknown | ∅ |
| Service contracts, auth mechanism and external dependencies | ∅ unknown | ∅ |

A configured URL is not proof of access. A Jira project key is not a token,
password or URL; never write credential values to Markdown or MCP config.
Choose provider and transport independently for each operation, with a manual
fallback. Every external write requires exact content/destination L4 approval.
Optional `.vscode/mcp.json` needs separate L5 preview and approval.
<!-- ai-qa:managed:end -->

<!-- ai-qa:user -->
Project-authored integration notes; preserve verbatim on refresh.
<!-- /ai-qa:user -->
