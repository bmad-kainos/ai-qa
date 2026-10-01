# Integrations conventions

Configure renders this source into `.github/ai-qa/project/conventions/integrations.md` after discovery and L5 approval. Configure identifies each provider deployment. Skills request provider operations and remain deployment-neutral. Record environment-variable names only; never secret values.

## Work items

| Field | Value | Status | Evidence/source |
|---|---|---|---|
| Provider | <Jira / ADO / other / none> | <status> | <configuration/source> |
| Deployment | <cloud / server-dc / n/a> | <status> | <serverInfo, config or confirmation> |
| Base URL | <public URL only> | <status> | <source/date> |
| Identifiers | <project key or collection/project IDs; no credentials> | <status> | <source> |
| Transports (preferred → fallback) | <MCP → CLI → REST → Manual> | <status> | <verified available operations> |
| Authentication method | <method only> | <status> | <source; never token value> |
| Environment variable names | <NAMES only> | <status> | <source> |
| Verified | <yes / no / unverified> | <status> | <read-only probe and date> |

## Docs

| Field | Value | Status | Evidence/source |
|---|---|---|---|
| Provider | <Confluence / Azure Wiki / other / none> | <status> | <configuration/source> |
| Deployment | <cloud / server-dc / n/a> | <status> | <serverInfo, config or confirmation> |
| Base URL | <public URL only> | <status> | <source/date> |
| Identifiers | <space, project or named root page> | <status> | <source> |
| Transports (preferred → fallback) | <MCP → CLI → REST → Manual> | <status> | <verified available operations> |
| Authentication method | <method only> | <status> | <source; never token value> |
| Environment variable names | <NAMES only> | <status> | <source> |
| Verified | <yes / no / unverified> | <status> | <read-only probe and date> |

## Repository and PRs

| Field | Value | Status | Evidence/source |
|---|---|---|---|
| Provider | <GitHub / Azure Repos / other / none> | <status> | <configuration/source> |
| Deployment | <cloud / server-dc / n/a> | <status> | <source> |
| Base URL | <public URL only> | <status> | <source/date> |
| Identifiers | <owner/repo or project/repo> | <status> | <source> |
| Transports (preferred → fallback) | <MCP → CLI → REST → Manual> | <status> | <verified available operations> |
| Authentication method | <method only> | <status> | <source; never token value> |
| Environment variable names | <NAMES only> | <status> | <source> |
| Verified | <yes / no / unverified> | <status> | <read-only probe and date> |

## CI

| Field | Value | Status | Evidence/source |
|---|---|---|---|
| Provider | <GitHub Actions / Azure Pipelines / other / none> | <status> | <configuration/source> |
| Deployment | <cloud / server-dc / n/a> | <status> | <source> |
| Base URL | <public URL only> | <status> | <source/date> |
| Identifiers | <organisation/project/pipeline> | <status> | <source> |
| Transports (preferred → fallback) | <MCP → CLI → REST → Manual> | <status> | <verified available operations> |
| Authentication method | <method only> | <status> | <source; never token value> |
| Environment variable names | <NAMES only> | <status> | <source> |
| Verified | <yes / no / unverified> | <status> | <read-only probe and date> |

If a preferred transport fails, disclose the failure and fall back. Manual operations must work: the user supplies input and generated output is written under `qa-work/<work-id>/outputs/`. Every external write is L4; `.vscode/mcp.json` is L5.