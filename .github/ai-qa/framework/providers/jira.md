# Jira Provider

Use the [provider contract](operations.md). A project key is an issue-key prefix, not a credential, base URL or permission grant. This provider implements `workitem.get`, `workitem.search`, `workitem.comment` and `workitem.create` through the configured transport.

## Deployment: Cloud

### Deployment and authentication

`*.atlassian.net` is only **◐ Inferred** Cloud evidence. Confirm deployment with a read-only `serverInfo` `deploymentType` probe or approved Atlassian MCP configuration; otherwise ask once. The Cloud REST base is the confirmed site URL and uses REST v3. Cloud REST authentication is Basic auth with `ATLASSIAN_EMAIL` and `ATLASSIAN_API_TOKEN` (or the configured environment-variable names in `conventions/integrations.md`). Use environment variables only; never echo, print, persist, or include their values in logs. Endpoints and command variants below are **unverified** until confirmed against the tenant and permissions.

**MCP hints:** use Atlassian remote MCP for Cloud if configured. Possible tool-name hints include `mcp_atlassian_mcp_jira_get_issue`, `mcp_atlassian_mcp_jira_search`, `mcp_atlassian_mcp_jira_add_comment`, and `mcp_atlassian_mcp_jira_create_issue`. Verify tool names, schemas, deployment and capability against the available tools. A community server such as `sooperset/mcp-atlassian` is another possible MCP transport; verify it supports this deployment and operation.

| Operation | MCP | CLI | REST | Manual |
|---|---|---|---|---|
| L0 `workitem.get` | Issue-get capability; request all normalized fields | No CLI in matrix | `GET /rest/api/3/issue/{key}`; discover AC field and fetch comments/links | User pastes issue plus source URL; mark unverified |
| L0 `workitem.search` | Bounded project-scoped JQL/search capability | No CLI in matrix | `POST /rest/api/3/search/jql`; follow returned cursor and state completeness | User pastes bounded results; mark unverified |
| L4 `workitem.comment` | Comment capability after exact preview and approval | No CLI in matrix | `POST /rest/api/3/issue/{key}/comment`; fetch/read back returned comment | Save approved-format comment and posting/read-back steps to `qa-work/<id>/outputs/` |
| L4 `workitem.create` | Create capability using discovered required fields | No CLI in matrix | `POST /rest/api/3/issue`; GET returned key to verify | Save title, project, type, fields and description in `outputs/`; not created |

### Read and search recipes

Request `summary`, `description`, `issuetype`, `status`, `issuelinks`, `comment`, and `updated`; also request the discovered AC field. `acceptance_criteria` is a normalized result, not a universal Jira field ID. Search must be scoped by confirmed project and query; `/search/jql` pagination uses the continuation returned by the tenant, not Server/DC `startAt` assumptions.

```text
curl --fail-with-body --silent --show-error --user "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" -H "Accept: application/json" "$BASE/rest/api/3/issue/PROJ-123?fields=summary,description,issuetype,status,issuelinks,comment,updated"
Invoke-RestMethod -Method Get -Uri "$Base/rest/api/3/issue/PROJ-123?fields=summary,description,issuetype,status,issuelinks,comment,updated" -Headers $Headers -ErrorAction Stop
curl --fail-with-body --silent --show-error -X POST --user "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" -H "Content-Type: application/json" --data-binary @approved-search.json "$BASE/rest/api/3/search/jql"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/3/search/jql" -Headers $Headers -ContentType "application/json" -InFile "approved-search.json" -ErrorAction Stop
```

In PowerShell, construct `$Headers` in memory from the environment variables and do not display it. Review request files locally and keep them out of source control. URI-encode keys and query values. A missing AC field, truncated comments or partial search must be reported as unknown/incomplete, not silently omitted.

### Create and comment recipes

Discover issue types, required/custom field IDs, permissions and supported description format first. Cloud descriptions and comments may require ADF; do not send wiki markup when ADF is required. The illustrative payload files below must contain a reviewed provider-native JSON body. Obtain the exact L4 approval before either write. After create, GET the returned issue key; after comment, GET the comment/issue and compare visible content. Never blindly retry a timed-out POST.

```text
curl --fail-with-body --silent --show-error -X POST --user "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" -H "Content-Type: application/json" --data-binary @approved-request.json "$BASE/rest/api/3/issue"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/3/issue" -Headers $Headers -ContentType "application/json" -InFile "approved-request.json" -ErrorAction Stop
curl --fail-with-body --silent --show-error -X POST --user "$ATLASSIAN_EMAIL:$ATLASSIAN_API_TOKEN" -H "Content-Type: application/json" --data-binary @approved-comment.json "$BASE/rest/api/3/issue/PROJ-123/comment"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/3/issue/PROJ-123/comment" -Headers $Headers -ContentType "application/json" -InFile "approved-comment.json" -ErrorAction Stop
```

**Manual:** if the preferred transport fails, state the failure and follow the configured fallback. With no approved transport, provide the paste-ready issue/comment, destination, required fields and verification checklist in `qa-work/<id>/outputs/`, marked `unverified / not created` or `unverified / not posted`. Do not claim an ID or URL.

## Deployment: Server/DC

### Deployment and authentication

A self-hosted/custom URL suggests Server/DC (**◐ Inferred**), not confirmed. Probe read-only `serverInfo` for `deploymentType` or use approved MCP configuration; otherwise ask once. Include the configured context path in `$BASE`. Use REST v2. Authentication may use a PAT Bearer token (`JIRA_PAT`) or approved Basic authentication; use only configured environment-variable names and never print credentials. Recipes and endpoint variants are **unverified** until confirmed against the instance.

**MCP hints:** an approved community MCP server such as `sooperset/mcp-atlassian` may support Jira Server/DC. Verify the installed tool names, deployment support, inputs and permissions. The Atlassian remote MCP is a Cloud hint; do not assume it connects to Server/DC.

**MCP server recipe (`sooperset/mcp-atlassian`, covers Jira and Confluence; Cloud and Server/DC):** it runs on demand as `uvx mcp-atlassian@<pinned-version>`, so install only the `uv` runtime first (Docker is the alternative, see below). Pin an exact, verified release (check the latest on PyPI) in both the previewed command and the `args` entry, so a later cache refresh cannot pull a different release; upgrades are a separately approved change. The first `uvx` invocation downloads and caches `mcp-atlassian`, which is dependency acquisition: preview that exact command and get separate L5 approval before it runs. Draft the `.vscode/mcp.json` entry with `inputs` so no secret is written, then ask separate L5 approval for each of: the write, any runtime install, the package or image acquisition (the first `uvx` run, `pipx run`, or `docker pull`), and, for Docker, the `docker run` command, because the written config launches it whenever VS Code starts the server. Do not write the config until all of these are approved. The JSON below is the **Server/DC** variant (personal access tokens, `*_PERSONAL_TOKEN`); use the Cloud variant for `*.atlassian.net`. Confirm variable names against the server's authentication docs before writing. Each product needs only its own URL and credential: drop the Confluence inputs and `env` keys if only Jira is used, and the Jira ones if only Confluence is used. **Unverified** until the server starts and a read-only tool call succeeds.

```json
{
  "inputs": [
    { "id": "jira-url", "type": "promptString", "description": "Jira base URL" },
    { "id": "jira-token", "type": "promptString", "description": "Jira personal access token", "password": true },
    { "id": "confluence-url", "type": "promptString", "description": "Confluence base URL" },
    { "id": "confluence-token", "type": "promptString", "description": "Confluence personal access token", "password": true }
  ],
  "servers": {
    "mcp-atlassian": {
      "type": "stdio",
      "command": "uvx",
      "args": ["mcp-atlassian@<pinned-version>"],
      "env": {
        "JIRA_URL": "${input:jira-url}",
        "JIRA_PERSONAL_TOKEN": "${input:jira-token}",
        "CONFLUENCE_URL": "${input:confluence-url}",
        "CONFLUENCE_PERSONAL_TOKEN": "${input:confluence-token}"
      }
    }
  }
}
```

Runtime preference: `uv`, then `pipx`, then Docker (or Podman). Runtime install (separate L5 approval, user's own machine) is offered only where an exact command is listed here: `uv` on macOS `brew install uv`, on Windows `winget install --id=astral-sh.uv -e`. For Linux and other systems, `pipx`, Docker and Podman, no install command is provided here: tell the user to follow the vendor's installation documentation themselves (Docker also needs a licence check and often admin rights), then re-run the lookup; if it is still absent, use the fallback. Never run a downloaded installer script on the user's behalf. Detect each tool first with a platform-appropriate read-only lookup: `command -v uvx` (POSIX shells) or `Get-Command uvx` (PowerShell); use the same lookup for `pipx` and `docker`.

**Cloud variant** (`*.atlassian.net`): replace the token inputs with an account email and an API token, and set the same `env` keys the server expects for Cloud.

```json
"env": {
  "JIRA_URL": "${input:jira-url}",
  "JIRA_USERNAME": "${input:atlassian-email}",
  "JIRA_API_TOKEN": "${input:atlassian-token}",
  "CONFLUENCE_URL": "${input:confluence-url}",
  "CONFLUENCE_USERNAME": "${input:atlassian-email}",
  "CONFLUENCE_API_TOKEN": "${input:atlassian-token}"
}
```

Add matching `promptString` inputs (`atlassian-email`, and `atlassian-token` with `"password": true`).

**pipx variant** (when `uv` cannot be installed but Python and `pipx` are available): same package, same pin and same first-run approval, since `pipx run` downloads and caches it. **Unverified** until it starts.

```json
"mcp-atlassian": {
  "type": "stdio",
  "command": "pipx",
  "args": ["run", "--spec", "mcp-atlassian==<pinned-version>", "mcp-atlassian"]
}
```

Use the same `env` block as the `uvx` variant for the deployment.

**Docker variant** (only if neither `uv` nor `pipx` is usable, and the user confirms they are licensed to use Docker; Podman is a compatible alternative with `command` set to `podman`): the server runs from its published image, so `command` is `docker`, not `uvx`. Pin a version tag rather than `latest`, preview the exact `docker pull <image>:<tag>` command and the exact `docker run` arguments and get separate L5 approval for each before the config is written. Pass each variable by name so values stay out of the file, and forward exactly the variables the deployment and the selected products need: drop the `-e` and `env` entries of any product not in use (Confluence-only users get no Jira entries, and the reverse). The example below is Server/DC with both products; for Cloud, forward `JIRA_USERNAME`, `JIRA_API_TOKEN`, `CONFLUENCE_USERNAME` and `CONFLUENCE_API_TOKEN` instead of the `*_PERSONAL_TOKEN` names, with the matching `env` values from the Cloud variant.

```json
"mcp-atlassian": {
  "type": "stdio",
  "command": "docker",
  "args": ["run", "--rm", "-i",
    "-e", "JIRA_URL", "-e", "JIRA_PERSONAL_TOKEN",
    "-e", "CONFLUENCE_URL", "-e", "CONFLUENCE_PERSONAL_TOKEN",
    "ghcr.io/sooperset/mcp-atlassian:<pinned-tag>"],
  "env": {
    "JIRA_URL": "${input:jira-url}",
    "JIRA_PERSONAL_TOKEN": "${input:jira-token}",
    "CONFLUENCE_URL": "${input:confluence-url}",
    "CONFLUENCE_PERSONAL_TOKEN": "${input:confluence-token}"
  }
}
```

Confirm the image name and tag against the server's installation docs before writing. After a VS Code reload, verify with a tool listing and one read-only call.

| Operation | MCP | CLI | REST | Manual |
|---|---|---|---|---|
| L0 `workitem.get` | Issue-get capability; verify normalized fields | No CLI in matrix | `GET /rest/api/2/issue/{key}`; discover AC field and fetch comments/links | User pastes issue plus source URL; mark unverified |
| L0 `workitem.search` | Bounded project-scoped JQL/search capability | No CLI in matrix | `POST /rest/api/2/search`, paginate by `startAt`/`maxResults` | User pastes bounded results; mark unverified |
| L4 `workitem.comment` | Comment capability after exact preview and approval | No CLI in matrix | `POST /rest/api/2/issue/{key}/comment`; read back | Save approved-format comment and posting/read-back steps to `outputs/` |
| L4 `workitem.create` | Create capability using discovered required fields | No CLI in matrix | `POST /rest/api/2/issue`; GET returned key | Save title, project, type, fields and description in `outputs/`; not created |

### Read and search recipes

Request summary, description, issue type, status, issue links, comments, and `updated`; discover and request the AC field. Scope JQL to the confirmed project. Continue until `startAt + returned count >= total` or the configured page limit, and report a bounded/partial result honestly. Treat Jira wiki markup or HTML as the instance's content, not Cloud ADF.

```text
curl --fail-with-body --silent --show-error -H "Authorization: Bearer $JIRA_PAT" -H "Accept: application/json" "$BASE/rest/api/2/issue/PROJ-123?fields=summary,description,issuetype,status,issuelinks,comment,updated"
Invoke-RestMethod -Method Get -Uri "$Base/rest/api/2/issue/PROJ-123?fields=summary,description,issuetype,status,issuelinks,comment,updated" -Headers $Headers -ErrorAction Stop
curl --fail-with-body --silent --show-error -X POST -H "Authorization: Bearer $JIRA_PAT" -H "Content-Type: application/json" --data-binary @approved-search.json "$BASE/rest/api/2/search"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/2/search" -Headers $Headers -ContentType "application/json" -InFile "approved-search.json" -ErrorAction Stop
```

`$Headers` is an in-memory PowerShell dictionary made from the configured environment variable; do not display it. If the instance uses Basic auth, use its approved environment-backed credential mechanism instead. Treat 403 and 404 as distinct failures; neither proves an item does not exist.

### Create and comment recipes

Discover issue types, field IDs, required fields, permission and supported description format. The Generic reference demonstrates issue GET/comment POST with PAT, but does not establish universal field IDs or implement search/create. Use wiki markup only when supported by this instance. Get exact L4 approval before the POST, then GET the returned issue/comment and compare the content. Do not blindly retry a timed-out POST.

```text
curl --fail-with-body --silent --show-error -X POST -H "Authorization: Bearer $JIRA_PAT" -H "Content-Type: application/json" --data-binary @approved-request.json "$BASE/rest/api/2/issue"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/2/issue" -Headers $Headers -ContentType "application/json" -InFile "approved-request.json" -ErrorAction Stop
curl --fail-with-body --silent --show-error -X POST -H "Authorization: Bearer $JIRA_PAT" -H "Content-Type: application/json" --data-binary @approved-comment.json "$BASE/rest/api/2/issue/PROJ-123/comment"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/2/issue/PROJ-123/comment" -Headers $Headers -ContentType "application/json" -InFile "approved-comment.json" -ErrorAction Stop
```

**Manual:** report the failed preferred transport, then follow configured fallbacks. If none is available, save exact paste-ready content and human verification instructions in `qa-work/<id>/outputs/`, labeled unverified. Never report an issue/comment as created or posted without authorized read-back.

## Format and safety rules

- Normalize `workitem.get` to title, description, acceptance criteria, type, status, links, comments and last-updated time. Preserve missing or permission-limited fields as `unknown`.
- Cloud REST v3 rich descriptions/comments may use ADF; Server/DC REST v2 may accept wiki markup or HTML. These formats are not interchangeable. Confirm the target instance's supported format before writing.
- Cloud search is `/rest/api/3/search/jql` with tenant-supported continuation; Server/DC search is `/rest/api/2/search` with `startAt` and `maxResults`. Verify each route and report incomplete results.
- For each operation, prefer the configured MCP transport, then the configured CLI/REST fallback only where the transport matrix allows it. CLI is not a supported Jira transport in the v1 matrix.
- If a preferred read fails, report it before using the next configured fallback. Manual reads require pasted input; manual writes require paste-ready output in `qa-work/<id>/outputs/`.
- L4 comments and creates always require a preview of action, target, exact payload and side effect, followed by explicit affirmative approval. Search for an existing comment/item before creating; on a timeout read/search to disambiguate, never blindly resubmit.
- Use only the configured base URL and environment variable names. Never reveal tokens, private issue bodies or request files in logs. Every recipe here is **unverified** until used with authorised access and read-back.

