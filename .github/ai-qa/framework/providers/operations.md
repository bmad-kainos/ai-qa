# Provider operations contract

This is a **documentation contract** for recipes, not an installed client API. A workflow may use approved MCP, CLI, REST or manual transport. A configured hostname provides **◐ inferred** deployment, not proof: confirm Atlassian Cloud versus Server/DC with an approved read-only `serverInfo` capability before selecting edition-specific endpoints. If confirmation fails, fall back to pasted/manual input. All required fields must be known before acting; `unknown` is a blocker, not a default.

Read project settings from `.github/ai-qa/project/project.md` and applicable `conventions/*.md`; only `qa-configure` changes those files. Once the L1 gate allows a work artifact, record non-sensitive provider source IDs, status and verification evidence in the corresponding `qa-work/<id>/index.md` or linked output. The `design`, `automate`, `full` and `triage` workflows still obey their L0–L5 gates; a provider recipe never bypasses an approval gate.

**L0 transport gate:** identify provider and likely deployment from configured hostname and project context, label the hostname result **◐ inferred**, then perform an approved **read-only** capability check (Atlassian `serverInfo` where available) to confirm Cloud versus Server/DC. Confirm tenant, permissions and approved credentials before remote reads; if the check fails, mark `blocked` and offer pasted/manual fallback rather than switching editions blindly. Only the eight named L0 operations below are read-only.

**L4 external-write gate:** preview destination, body/format and diff; obtain explicit user approval for the exact `workitem.comment`, `workitem.create`, `docs.publish` or `repo.pr.create` action. Other external writes, including pipeline triggers and uploads, also require a distinct L4 approval and cannot be inferred from read-only operations. Verify by a new read after publication; if transport fails or approval is absent, save a paste-ready **manual** input/output handoff in approved `qa-work/<id>/outputs/` (after L1) labeled `unverified / not published`. Do not invent a remote URL/ID or mark `verified` without read-back.

## Named operation catalog

| Gate | Operation | Required input and normalized result |
|---|---|---|
| L0 | `workitem.get` | `resource_id` (issue key/work item ID): `title`, `description`, `acceptance_criteria` (AC), `type`, `status`, `links`, `comments`, `updated` (last-modified timestamp). Missing/permission-limited fields remain `unknown`, never fabricated. |
| L0 | `workitem.search` | Scoped query and finite page size: canonical work item IDs, titles/status and next-page/partial-result indicator. |
| L0 | `docs.search` | Scoped space/wiki query and pagination: canonical page IDs, titles, paths/URLs and continuation. |
| L0 | `docs.get` | Page ID/path: body in actual format, title, parent/space/wiki, version/ETag and URL. |
| L0 | `repo.pr.list` | Repository, state and bounded page: PR ID/number, title, head/base, status, URL and continuation. |
| L0 | `ci.runs` | Repository/project and pipeline/workflow ID: bounded run IDs, timestamps, state/result and continuation. |
| L0 | `ci.run.get` | Run ID: run/commit/ref, state, conclusion, URL, timestamps and relevant jobs. |
| L0 | `ci.test-results` | Run ID: provider-supported test result counts, failures, report/artifact URLs and completeness; `unsupported` if not exposed. |
| L4 | `workitem.comment` | Work item ID, approved comment body and destination: returned comment ID/URL and read-back. |
| L4 | `workitem.create` | Project/type, confirmed required fields and approved title/body: returned work item ID/URL and read-back. |
| L4 | `docs.publish` | `mode: create/update/append`, space/wiki/parent/path, approved body/format and `expected_version` for update/append: returned page ID/version and read-back. |
| L4 | `repo.pr.create` | Repository, existing head/base, approved title/body and review of diff: returned PR ID/URL/head/base and read-back. |

An unsupported provider/transport combination returns `unsupported`; it must never be silently replaced with a different operation. `ci.test-results` is not a guess based on a green build: if detailed results are unavailable, report `unknown`/`unsupported`.

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

For any named read, scope and paginate deliberately, preserve actual source format/version and report incomplete/permission-limited results. For `docs.publish(update/append)`, re-read full body/version, preview conversion and diff, reject stale versions, write and read back. For any L4 write, a 2xx response alone does not verify rendered content. A failed MCP/CLI/REST attempt is not permission to try another write route without approval.

When MCP/CLI/REST is unavailable or a write is not approved, return a **manual** handoff with destination, title, paste-ready input/output content in the correct provider format, required fields, link/attachment checklist and explicit human verification steps in `qa-work/<id>/outputs/`. Set `status: unverified`, `canonical_id: unknown`, and `evidence: manual draft; no remote write`; never state "created" or "published". Use [provider recipes](README.md) only as deployment-specific examples.
