# Provider operations contract

This is a documentation contract for provider recipes, not an installed client API. Skills request named operations; provider, deployment and transport are selected from `.github/ai-qa/project/conventions/integrations.md`. Read project settings from `.github/ai-qa/project/project.md` and applicable conventions; only `qa-configure` writes the project layer. A provider recipe never bypasses the L0-L5 rules in `.github/ai-qa/framework/method/safety.md`.

Provider files (`jira.md`, `confluence.md`, `azure-devops.md`, `azure-wiki.md`, `github.md`) are **transport recipes, not executable connectors**. No recipe claims that an MCP tool is installed, that credentials are configured, or that a remote call has succeeded. Every recipe is **unverified** until the configured transport is authorised and a real read-back succeeds. On 401/403/404 report the actual failure rather than a nonexistent item, and retry 429/5xx with bounded back-off for reads only; never blindly retry a non-idempotent write.

## Deployment identification

For Atlassian, `*.atlassian.net` suggests Cloud (**◐ Inferred**); a self-hosted/custom URL suggests Server/DC (**◐ Inferred**). Record the basis and sample URL without credentials. Confirm with an approved read-only `serverInfo` `deploymentType` probe or the configured Atlassian MCP server's deployment metadata. If neither can confirm it, ask once which deployment is configured; do not guess an edition or try a different host. For other providers, use the deployment recorded in `conventions/integrations.md`; an URL alone does not prove access or capability.

## Transport matrix

`✓` supported transport in the v1 matrix; `—` not a listed transport. Support is not proof that a tool, CLI, credential or permission is available in this workspace. `◐` means inferred, not verified.

| Capability | MCP | CLI | REST recipe | Manual |
|---|---:|---:|---:|---:|
| Jira Cloud | ✓ | — | ✓ | ✓ |
| Jira Server/DC | ✓ | — | ✓ | ✓ |
| Confluence Cloud | ✓ | — | ✓ | ✓ |
| Confluence Server/DC | ✓ | — | ✓ | ✓ |
| Azure DevOps Boards | ✓ | `az boards` | ✓ | ✓ |
| Azure Wiki | ✓ | `az devops wiki` | ✓ | ✓ |
| Azure Repos PR | ✓ | `az repos pr` | — | ✓ |
| Azure Pipelines | — | `az pipelines` | ✓ | ✓ |
| GitHub PR and Actions | ✓ | `gh` | — | ✓ |

## Operation contract

All reads are scoped and bounded. Return every required field or an explicit `unknown`/`unsupported`; never infer missing data. Provider-native field names must be normalised to these names.

| Level | Operation | Required inputs | Required returned fields |
|---|---|---|---|
| L0 | `workitem.get` | provider, deployment, `resource_id` (issue key/work-item ID), confirmed scope | `title`, `description`, `acceptance_criteria` (ACs), `type`, `status`, `links`, `comments`, `updated` (last-modified timestamp); missing values are `unknown` |
| L0 | `workitem.search` | provider, deployment, scoped query (JQL/WIQL/provider query), finite `page_size`, optional cursor | canonical work-item IDs, titles, status, continuation or `none`, partial/completeness indicator |
| L0 | `docs.search` | provider, deployment, confirmed space/wiki, scoped query, finite `page_size`, optional cursor | canonical page IDs, titles, paths/URLs, continuation or `none`, partial/completeness indicator |
| L0 | `docs.get` | provider, deployment, page ID/path and scope | actual body and `body_format`, title, parent/space/wiki, version/ETag, canonical URL |
| L0 | `repo.pr.list` | provider, repository, state/filter, finite `page_size`, optional cursor | PR ID/number, title, head, base, status/draft state, URL, continuation/completeness |
| L0 | `ci.runs` | provider, repository/project, pipeline/workflow ID, bounded query and page size | run IDs, timestamps, state/result, URL where available, continuation/completeness |
| L0 | `ci.run.get` | provider, repository/project, run ID | run/commit/ref, state, conclusion, URL, timestamps, relevant jobs |
| L0 | `ci.test-results` | provider, repository/project, run ID | provider-supported test counts, failures, report/artifact URLs, completeness; `unsupported` if not exposed |
| L4 | `workitem.comment` | provider, deployment, work-item ID, exact approved body and target | actual comment ID/URL and read-back result |
| L4 | `workitem.create` | provider, deployment, project/type, confirmed required fields, exact approved title/body | actual work-item ID/URL and read-back result |
| L4 | `docs.publish` (`create`) | provider, deployment, space/wiki/parent/path, exact approved title/body/format | actual page ID/version/URL and read-back result |
| L4 | `docs.publish` (`update` or `append`) | same, plus page ID, fresh source version/ETag and expected version | actual page ID/new version/URL and read-back result |
| L4 | `repo.pr.create` | provider, repository, existing head/base, reviewed diff, exact approved title/body | actual PR ID/URL/head/base/draft state and read-back result |

`ci.test-results` is not inferred from a green build: if detailed results are unavailable, report `unknown` or `unsupported`.

## Request fields

| Field | Required | Meaning |
|---|---|---|
| `provider` | Yes | `jira`, `confluence`, `azure-devops`, `azure-wiki` or `github` |
| `deployment` | Yes | `cloud`, `server-dc`, `services`, `server`, or `github.com/enterprise` as appropriate; `unknown` blocks remote operations |
| `operation` | Yes | one exact named operation in the catalog; `docs.publish` also requires `mode` |
| `transport` | Yes | approved `mcp`, `cli`, `rest` or `manual`; record tool/command capability, not credentials |
| `base_url` | For REST/CLI | confirmed organization/tenant/collection/repository URL without credentials |
| `scope` | For scoped reads/writes | project/space/repository/wiki/pipeline and permitted environment |
| `resource_id` | For item/page/run-specific operations | provider-native key/ID/path; never fabricated |
| `query`, `page_size`, `cursor` | For search/list | bounded scoped query, finite page size and edition-specific continuation |
| `title`, `body`, `body_format`, `fields` | For L4 writes | human-reviewed provider-native content and discovered fields |
| `mode`, `expected_version` | `docs.publish` | `create`, `update` or `append`; version/ETag required for update/append |
| `head`, `base` | `repo.pr.create` | existing confirmed branches; no implicit branch creation |
| `approval` | For L4 writes | explicit user approval specifying destination and side effect |

Use approved secret storage for authentication and never include credential values in requests, output, generated Markdown or shell history. Encode untrusted path/query components with the transport's URI encoder, validate a trusted HTTPS base URL, and respect the edition's content representation. Never execute a command printed in these recipes without confirming destination, auth scope and action.

## Result fields

| Field | Required | Meaning |
|---|---|---|
| `provider`, `deployment`, `operation`, `transport` | Yes | The selected and actually used route |
| `status` | Yes | `verified`, `unverified`, `blocked`, `unsupported` or `failed` |
| `canonical_id`, `url` | If known | Actual provider response identifiers; never invent on manual fallback |
| `title`, `description`, `acceptance_criteria`, `type`, `status`, `links`, `comments`, `updated` | `workitem.get` | Observed fields; explicit `unknown` if absent or access-limited |
| `body_format`, `source_version`, `mode` | When relevant | Actual representation and revision/ETag; publish mode |
| `observed_at` | Yes | UTC time of actual observation, not draft generation |
| `evidence` | Yes | redacted tool/endpoint, HTTP status, actual nonsecret response identifier and read-back outcome, or reason unavailable |
| `next_page` | For paginated reads | Provider continuation token/link, or explicit `none` after the final page |
| `warnings` | Yes | Permission, fidelity, conversion, conflicts, partial data or unverified side effects |

**Status rules:** `verified` means an authorized read observed the claimed state (for writes, re-read *after* the write and compare content/version/attachments); a locally drafted page, 2xx write response, returned ID or illustrative endpoint is still `unverified`. `blocked` means required approval/access/environment is missing; `unsupported` means this edition/tool cannot perform the operation; `failed` means an attempted authorized operation returned an error. Never translate 403 to a nonexistent item. Include only non-sensitive evidence and restrict private-content dissemination.

## Execution and manual fallback

1. Read `conventions/integrations.md` for the capability's provider, deployment, base URL, identifiers, preferred-to-fallback transports, authentication method and environment-variable names. Verify the transport is actually available and authorised.
2. Use the configured preferred transport. MCP tool-name hints in provider files are discovery hints only: verify names and supported inputs against available tools. CLI commands require an already-installed, authenticated CLI. REST is a recipe, not a client. Do not install dependencies or write `.vscode/mcp.json` here (only `qa-configure` does, with L5 approval).
3. If the preferred transport fails, report which transport failed and why, then offer the next configured fallback. Do not silently switch tenant, deployment, auth scope or operation. Never blindly retry a non-idempotent write. A second transport for a write requires the same still-valid exact L4 approval; if target/payload changes, show it and ask again.
4. If no approved transport works, use Manual: ask the user to paste source material or search results for reads; provide paste-ready provider-format content and destination instructions for writes. Write the handoff only to `qa-work/<work-id>/outputs/` after local L1 conditions are met. Label it `unverified / not published` (or `not created`); do not claim a remote ID or URL.

For L4, show action, target, exact payload and side effect, then wait for explicit affirmative approval immediately before acting. After a write, read the result back; a 2xx response or returned ID alone is not verification. Report actual ID/URL and verification status, then log approval/action/result in `qa-work/<work-id>/index.md`. Other external writes such as pipeline triggers or uploads require their own L4 approval and are outside this operation catalog.

## Provenance

Confluence Server/DC read/update/append and conversion facts, and Jira Server/DC issue and comment behaviour, derive from `sylwia-luczak/AI-QA-AGENT_GENERIC` at `ac750bb` (`tools/confluence_tool.py`, `tools/jira_tool.py` and the scenario-format guidance). That source declares no licence, so these files paraphrase behaviour and import no code. Other deployment and API examples remain **unverified** against any live tenant.
