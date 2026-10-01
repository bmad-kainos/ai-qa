# Azure DevOps work items — transport recipe

Use the [provider contract](operations.md). Confirm organization, project, area/iteration, work item type, field names, process template and permission. Azure DevOps Services and Azure DevOps Server may differ in supported API versions and base paths; this is **unverified guidance**, not a claim that an ADO connector exists.

| Named operation | MCP hint | CLI | REST and verification | Manual |
|---|---|---|---|---|
| L0 `workitem.get` / `workitem.search` | Approved Boards get/scoped query | `az boards work-item show` / `az boards query` if installed | GET WIT ID / POST WIQL, fetch all required fields including AC/comments/links/updated; paginate/batch | Pasted ticket/query results, unverified |
| L4 `workitem.comment` / `workitem.create` | Approved Boards comment/create capability | `az boards work-item update --discussion` if supported / `create` after approval | Comments endpoint if edition supports it / JSON Patch create, re-read | Paste-ready draft in `outputs/`, unverified |
| L0 `repo.pr.list` / L4 `repo.pr.create` | Approved Repos PR list/create | `az repos pr list` / `az repos pr create`, approved | No promised REST fallback for PR write | Paste-ready PR in `outputs/`, unverified |
| L0 `ci.runs` / `ci.run.get` | Approved Pipelines run list/detail | `az pipelines runs list` / `runs show` | Pipelines runs list/GET exact run, check edition | Human-supplied run list/detail, unverified |
| L0 `ci.test-results` | Approved test results capability linked to run | `az pipelines runs show` does **not** prove test results; use only supported test-result command | Discover linked test run ID, query Test Results API if supported | Exported test report with provenance, unverified |

- **Read:** use approved Azure DevOps tool or `GET https://dev.azure.com/{org}/{project}/_apis/wit/workitems/{id}?api-version=<supported-version>` for Services. For Server, use its configured collection/project URL and a supported API version. Capture work item ID, revision, title, description, state and canonical URL.
- **Search:** scoped WIQL query for IDs, then fetch selected fields by ID in bounded batches; paginate/batch deliberately. Do not expose unrestricted queries across projects.
- **Create:** with approval, use Work Item Tracking JSON Patch (`Content-Type: application/json-patch+json`) on `POST .../_apis/wit/workitems/$<type>?api-version=...`, including confirmed required fields. Resolve area, type and identity from project metadata; never infer defaults.
- **Update:** fetch current revision, show diff and use a JSON Patch `test` on `/rev` before replacements/additions. On conflict, stop and re-review; then re-fetch and verify.
- **Links/attachments:** upload only approved material and attach/link by approved relation type; check returned IDs and final relations.

Keep PAT/OAuth credentials in approved stores. A successful PATCH is **unverified** until the work item is re-read and the requested fields match. If unavailable, provide paste-ready work item title/type/description/acceptance criteria and human creation instructions; mark **unverified / not created**.

## Choose deployment and transport

**MCP:** Check that the approved Azure DevOps tool supports this organization/project, work item types and the requested read/write operation; never infer tool availability. **REST:** `$BASE` is a confirmed Services `https://dev.azure.com/{org}/{project}` or Server collection/project URL. `$API_VERSION` is checked against that deployment; `7.1` is a Services example, **unverified** for Server. Curl `-H "@$AUTH_HEADER_FILE"` reads a permission-restricted header file from approved secret storage outside the repo, keeping credentials out of process argv; PowerShell `$Headers` is in-memory. Never print tokens or put them in shell history. Review request bodies in `approved-*.json` outside source control. URI-encode path/type/query values.

### Get and search/list (Services and compatible Server)

Use GET to capture ID, `rev`, `System.Title`, `System.Description`, state and canonical URL. WIQL search returns IDs, not all work-item fields: POST a project-scoped WIQL query with bounded filters, then fetch selected IDs in batches with required fields. Observe result limits; don't imply an unpaginated query is complete. On Server use its actual collection URL and supported version.

```text
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" "$BASE/_apis/wit/workitems/123?api-version=$API_VERSION"
Invoke-RestMethod -Method Get -Uri "$Base/_apis/wit/workitems/123?api-version=$ApiVersion" -Headers $Headers -ErrorAction Stop
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-wiql.json "$BASE/_apis/wit/wiql?api-version=$API_VERSION"
Invoke-RestMethod -Method Post -Uri "$Base/_apis/wit/wiql?api-version=$ApiVersion" -Headers $Headers -ContentType "application/json" -InFile "approved-wiql.json" -ErrorAction Stop
```

### Create, update, link/attach and verify

Discover work-item type and required fields from the process template. After preview/approval, POST JSON Patch with `Content-Type: application/json-patch+json` to `.../workitems/$<encoded-type>`. This `$` is part of the Azure DevOps route, not a shell variable: ensure URI construction preserves it. For update, GET current `rev`, include a JSON Patch `test` operation on `/rev`, then PATCH `/workitems/{id}`. Re-read ID/revision/fields; do not retry a timed-out create until searching for an existing matching item. Use approved relation type for a link; for attachments obtain the returned upload URL and add the attachment relation, then re-read relations. Do not upload secret/private evidence without separate authorization.

```text
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json-patch+json" --data-binary @approved-create.json "$BASE/_apis/wit/workitems/\$Task?api-version=$API_VERSION"
Invoke-RestMethod -Method Post -Uri ($Base + '/_apis/wit/workitems/$Task?api-version=' + $ApiVersion) -Headers $Headers -ContentType "application/json-patch+json" -InFile "approved-create.json" -ErrorAction Stop
curl --fail-with-body --silent --show-error -X PATCH -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json-patch+json" --data-binary @approved-update.json "$BASE/_apis/wit/workitems/123?api-version=$API_VERSION"
Invoke-RestMethod -Method Patch -Uri "$Base/_apis/wit/workitems/123?api-version=$ApiVersion" -Headers $Headers -ContentType "application/json-patch+json" -InFile "approved-update.json" -ErrorAction Stop
```

Confirm the HTTP method and `Content-Type` supported by the configured Server version before use. **Manual variant (unverified):** hand off the exact project/type/area/title/description and a checklist for the human to capture the resulting ID, revision and visible fields; never claim a created item without read-back.

## Azure Boards: `az` CLI alternative

If the Azure DevOps CLI extension is already installed and authenticated, first confirm its commands and `--organization`/`--project` flags for the configured deployment (`AZURE_DEVOPS_EXT_PAT` is an **environment variable name**, not a value to store here). These are **unverified** recipe shapes; do not install an extension or alter CLI defaults merely to read a ticket. For a work item, prefer a bounded, project-scoped WIQL query and read by ID. After L4 approval, `az boards work-item create --type <confirmed-type> --title <approved-title> --organization <org-url> --project <project>` or `az boards work-item update --id <id> ...` may be used with exact flags discovered from help; re-read the item and compare all changed fields. CLI argument values can appear in process lists/history: for sensitive body text choose approved protected request transport/manual handoff rather than CLI flags.

```text
az boards work-item show --id 123 --organization <org-url> --project <project> --output json
az boards query --wiql "SELECT [System.Id] FROM WorkItems WHERE [System.TeamProject] = @project" --organization <org-url> --project <project> --output json
```

## Azure Repos pull requests: MCP → `az` CLI → manual

Confirm project, repository, source/target branches, diff, reviewer identities and write permission. An approved MCP PR tool may read/list/create only its documented capabilities. With an existing authenticated Azure DevOps CLI, `az repos pr show --id <pr-id> --organization <org-url>` and `az repos pr list --repository <repo> --project <project> --organization <org-url>` are read routes. Creating a PR is an L4 external write: preview diff/description/target, use `az repos pr create --repository <repo> --source-branch <source> --target-branch <target> --title <approved-title> --description <approved-description> --organization <org-url> --project <project>` only if supported and approved, then read the returned PR. Do not silently create branches, complete a PR or add reviewers. There is **no promised REST fallback** for PR publishing in this recipe; if tool/CLI fails, prepare paste-ready PR title/body, branch details and manual creation/read-back checklist in `outputs/`, `unverified`.

## Azure Pipelines: MCP/`az` CLI/REST/manual

Read-only: confirm pipeline ID and permissions. `az pipelines show --id <pipeline-id> --organization <org-url> --project <project>` and `az pipelines runs show --id <run-id> ...` are CLI candidates only when installed/supported. For Services REST, GET runs with `$BASE/_apis/pipelines/{pipeline-id}/runs?api-version=$API_VERSION` or exact run by ID; on Server verify that this API exists before use. Queueing a run is an L4 external action with potential deployments/cost: preview branch, parameters, variables, environment and side effects; obtain *separate* explicit approval. `az pipelines run --id <pipeline-id> --branch <approved-branch> --organization <org-url> --project <project>` is a CLI candidate when supported; POST reviewed JSON to `/runs` is a REST alternative for a supported instance. Do not expose secrets in parameters or shell arguments. Re-read run ID, state and result; a queued run is not a passed run.

```text
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" "$BASE/_apis/pipelines/42/runs/314?api-version=$API_VERSION"
Invoke-RestMethod -Method Get -Uri "$Base/_apis/pipelines/42/runs/314?api-version=$ApiVersion" -Headers $Headers -ErrorAction Stop
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-pipeline-run.json "$BASE/_apis/pipelines/42/runs?api-version=$API_VERSION"
Invoke-RestMethod -Method Post -Uri "$Base/_apis/pipelines/42/runs?api-version=$ApiVersion" -Headers $Headers -ContentType "application/json" -InFile "approved-pipeline-run.json" -ErrorAction Stop
```

No supported transport? Save pipeline ID, exact branch/parameters, expected side effects and a human queue/read-back checklist in approved `qa-work/<id>/outputs/`; `unverified / not queued`. No remote pipeline state is inferred from local output.

### Named comment and test-result details

For `workitem.comment`, confirm whether the instance supports `/_apis/wit/workItems/{id}/comments` and its *edition-specific preview API version* before POST. Fetch the comment collection and compare the returned ID/body after L4 approval; a description update is not a comment. A supported CLI `az boards work-item update --id <id> --discussion <approved-text> ...` may expose private text in process history, so prefer an approved protected tool/REST body or manual paste. Unsupported version → `unsupported`, not a silent PATCH of description.

`ci.test-results` is not the same as `ci.run.get`: a pipeline run ID may not equal an Azure Test **run** ID. Discover the test run linked to the pipeline/build, then use the deployment-supported Test Results route such as `GET /_apis/test/Runs/{test-run-id}/results?api-version=<supported-version>` with bounded pages and return actual totals/failures/artifact links. If the association or permissions are missing, set `unsupported`/`unknown`; never derive passed test counts from pipeline conclusion alone. `ci.runs` likewise pages the Pipelines runs endpoint, rather than assuming an exact run GET enumerates all runs.
