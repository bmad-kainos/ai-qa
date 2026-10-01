# Jira — Cloud versus Server/Data Center

Use the [provider contract](README.md). A Jira **project key** is an issue-ID prefix (`PROJ` in `PROJ-123`), not a credential, base URL or permission grant. This provider supports only the named `workitem.get`, `workitem.search`, `workitem.comment` and `workitem.create` operations.

| Named operation | MCP hint | CLI | REST and verification | Manual |
|---|---|---|---|---|
| L0 `workitem.get` | Approved issue-get capability; request title, description, AC, type, status, links, comments, updated | No CLI assumed | Cloud v3 / Server/DC v2 issue GET; normalize missing AC to `unknown` | Pasted issue and provenance, unverified |
| L0 `workitem.search` | Approved project-scoped search/JQL capability | No CLI assumed | Cloud scoped `/search/jql` or Server/DC `/search`, paginate | Human supplies search result list, unverified |
| L4 `workitem.comment` | Approved comment capability after exact preview/approval | No CLI assumed | Edition-specific POST comment, then GET comment/issue | Paste-ready comment in `outputs/`, not posted |
| L4 `workitem.create` | Approved create capability with discovered fields | No CLI assumed | Edition-specific issue POST, then GET returned key | Paste-ready issue in `outputs/`, not created |

| Operation | Jira Cloud recipe | Jira Server/Data Center recipe |
|---|---|---|
| Discover | Check configured site and accessible project/field metadata, issue types and permissions; approved OAuth/API-token mechanism. | Check site-specific REST version, project/field metadata, issue types and permissions; approved PAT/session/OAuth mechanism as configured. |
| Read | `GET /rest/api/3/issue/{key}` with required fields; descriptions and rich text may be Atlassian Document Format (ADF). | `GET /rest/api/2/issue/{key}`; descriptions may be Jira wiki markup or HTML, not necessarily ADF. |
| Search | `POST /rest/api/3/search/jql` with scoped JQL and pagination as supported by tenant; capability-check before use. | `POST /rest/api/2/search` with scoped JQL, `startAt`/`maxResults`; check instance REST version. |
| Create | `POST /rest/api/3/issue` using discovered field IDs and Cloud ADF description where required; re-fetch issue. | `POST /rest/api/2/issue` using instance-specific field IDs and supported description representation; re-fetch issue. |
| Comment | `POST /rest/api/3/issue/{key}/comment`, Cloud ADF when required; re-fetch comment. | `POST /rest/api/2/issue/{key}/comment`, instance format; re-fetch comment. |

**Unverified transport recipes:** endpoint shape alone does not verify tenant support, authentication, permissions or output. For any query, confirm JQL scope and pagination; avoid assuming search results are complete.

**Manual fallback:** provide a paste-ready Jira issue/comment draft (summary, project, type, description, acceptance criteria and relevant links) and a human checklist to post it in the confirmed Jira deployment, inspect formatting and capture canonical issue/comment ID. Label **unverified / not created** until independently read back.

## Transport prerequisites

**MCP:** If an approved Jira tool exposes the required operation for the confirmed deployment, use its documented inputs (project key, issue key, bounded JQL, fields); do not assume a tool named in another installation is available. Read the issue after any tool-mediated write. **REST:** The examples below are **unverified recipes**, not commands to execute automatically. `$BASE` is a trusted site URL (including on-prem context path). Curl reads auth via `-H "@$AUTH_HEADER_FILE"` from a permission-restricted header file provisioned by an approved secret store **outside the repo**; only the path variable is expanded into process arguments, never the secret. In PowerShell `$Headers` is an approved in-memory authentication header dictionary; never put secret values into command text/history. URI-encode issue keys and query inputs; review `approved-request.json` locally and keep it out of source control. Cloud v3 ADF and Server/DC v2 description formats are not interchangeable. GET/search can contain private issue content; avoid logging responses.

**L0 deployment check:** an `*.atlassian.net` hostname suggests Cloud; an internal/custom hostname suggests Server/DC, but neither proves deployment. On the *configured trusted site* use an approved read-only `serverInfo` capability (`/rest/api/3/serverInfo` for Cloud candidates, `/rest/api/2/serverInfo` for Server/DC candidates) and confirm response/product/version before selecting an edition. If unavailable, ask the administrator or use pasted/manual input; do not silently switch endpoints or tenants. No write before L4 approval.

The pinned Generic Server/DC Jira reference (`sylwia-luczak/AI-QA-AGENT_GENERIC`, `ac750bb64d8a34de65c0d0aa6e7f27ecbd366698`, `tools/jira_tool.py`) demonstrates issue GET and comment POST using a PAT; it does **not** implement JQL search or issue creation. The search/create recipes here are separately **unverified transport variants**, not claims about that tool. The reference reads issue links, subtasks and comments but does not establish a universal AC custom-field ID or guarantee all paginated comments; discover AC mapping, request `updated` explicitly and fetch additional comment pages when needed. Its comment-edit operation is outside the v1 named provider contract. Never import or run the reference script as part of this Markdown pack.

### Jira Cloud: read and search

Read one issue with selected `fields`, then inspect `key`, `fields`, `updated` and rendered body before analysis. Search with project-scoped JQL, `maxResults` and `nextPageToken` when returned by `/search/jql`; do not reuse Server/DC `startAt` behavior as a Cloud cursor. The JSON search body is a reviewed local request, not a hardcoded token.

```text
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" -H "Accept: application/json" "$BASE/rest/api/3/issue/PROJ-123?fields=summary,description,status,updated"
Invoke-RestMethod -Method Get -Uri "$Base/rest/api/3/issue/PROJ-123?fields=summary,description,status,updated" -Headers $Headers -ErrorAction Stop
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-search.json "$BASE/rest/api/3/search/jql"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/3/search/jql" -Headers $Headers -ContentType "application/json" -InFile "approved-search.json" -ErrorAction Stop
```

If `/search/jql` or its pagination differs on the tenant, inspect the tenant's supported search API; mark unsupported or blocked rather than silently assuming an older route.

### Jira Cloud: create and verify

Discover project issue types, required/custom field IDs and permissions first. Preview Cloud ADF and destination, obtain explicit approval, then POST approved JSON to `/rest/api/3/issue`. Verify returned issue key by GET. Never blindly retry a timed-out POST.

```text
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-request.json "$BASE/rest/api/3/issue"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/3/issue" -Headers $Headers -ContentType "application/json" -InFile "approved-request.json" -ErrorAction Stop
```

### Jira Server/Data Center: read and search

Confirm `/rest/api/2` and supported authentication on the instance, including its context path. Search via scoped JQL with `startAt` and `maxResults`; advance until `startAt + returned count >= total` or policy limit. Parse wiki-markup descriptions as data, not Cloud ADF.

```text
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" -H "Accept: application/json" "$BASE/rest/api/2/issue/PROJ-123?fields=summary,description,status,updated"
Invoke-RestMethod -Method Get -Uri "$Base/rest/api/2/issue/PROJ-123?fields=summary,description,status,updated" -Headers $Headers -ErrorAction Stop
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-search.json "$BASE/rest/api/2/search"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/2/search" -Headers $Headers -ContentType "application/json" -InFile "approved-search.json" -ErrorAction Stop
```

### Jira Server/Data Center: create and verify

Use instance-discovered field IDs/type and the supported description representation. Preview destination and get L4 approval. Create under `/rest/api/2/issue`, then verify by GET.

```text
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-request.json "$BASE/rest/api/2/issue"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/2/issue" -Headers $Headers -ContentType "application/json" -InFile "approved-request.json" -ErrorAction Stop
```

**Manual-only variant:** no approved credentials, unsupported write or inadequate permission → provide a draft and explicit human verification steps. `status: unverified`; do not fabricate issue keys.

### Named `workitem.comment` (Cloud and Server/DC)

At L4, preview exact comment and issue key; Cloud comment body may require ADF whereas Server/DC may accept wiki/plain markup. POST to the **confirmed** edition's `/rest/api/{3|2}/issue/{key}/comment` with reviewed JSON, then GET comment ID and issue to verify visible text. These are **unverified** route recipes; no write without approval.

```text
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-comment.json "$BASE/rest/api/3/issue/PROJ-123/comment"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/3/issue/PROJ-123/comment" -Headers $Headers -ContentType "application/json" -InFile "approved-comment.json" -ErrorAction Stop
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-comment.json "$BASE/rest/api/2/issue/PROJ-123/comment"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/2/issue/PROJ-123/comment" -Headers $Headers -ContentType "application/json" -InFile "approved-comment.json" -ErrorAction Stop
```
