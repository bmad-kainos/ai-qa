# Confluence — Cloud versus Server/Data Center

Use the [provider contract](README.md). Determine deployment, space key, page ID, parent, content representation and edit permission. A rendered Markdown preview is not a valid Confluence storage body; convert/validate supported rich content carefully, preserving links, tables and code blocks. Treat macros, attachments and embedded content as potentially lossy.

| Named operation | MCP hint | CLI | REST and verification | Manual |
|---|---|---|---|---|
| L0 `docs.search` | Approved space-scoped page search | No CLI assumed | Cloud v2 cursor/v1 CQL or Server/DC spaceKey+title/CQL, paginate | Human-supplied page list, unverified |
| L0 `docs.get` | Approved page-get with body and version | No CLI assumed | Cloud v2/v1 or Server/DC content GET, preserve storage/version | Pasted page and source URL, unverified |
| L4 `docs.publish` `create` | Approved create only after preview/approval | No CLI assumed | Confirm space/parent, POST, read back new page | Paste-ready page in `outputs/`, not published |
| L4 `docs.publish` `update`/`append` | Approved update with current version | No CLI assumed | Fresh GET, diff/convert, versioned PUT, read back | Human diff and instructions in `outputs/`, not published |

| Operation | Confluence Cloud recipe | Confluence Server/Data Center recipe |
|---|---|---|
| Read | REST v2 `GET /wiki/api/v2/pages/{id}?body-format=storage` when supported; some capabilities still require v1 `/wiki/rest/api/content/{id}?expand=body.storage,version`. | REST `/rest/api/content/{id}?expand=body.storage,version,space,ancestors` with base context path configured for the instance. |
| Search/list | Cloud v2 space/page listing with cursor links; use Cloud v1 CQL if required and supported. Scope by space, handle cursors. | For a known title, `GET /rest/api/content?spaceKey={space}&title={title}&expand=version,space`; for broader searches use supported scoped CQL with `start`/`limit`, respecting `_links.next`. Confirm title match and space before edits. |
| Create | Cloud v2 page create with space ID, parent ID and supported body representation; check format/permission first. | POST `/rest/api/content` with type `page`, space key, optional ancestors and `body.storage`; check instance API. |
| Update | Cloud v2 update includes current version and supported representation; re-read before and after write. | PUT `/rest/api/content/{id}` with type `page`, existing title, `body.storage` (`representation: storage`) and current version + 1; re-read immediately before and after write, do not overwrite stale edits. |
| Attach | Use supported edition-specific attachment endpoint and upload requirements; validate size and final attachment listing. | Use server attachment endpoint/context path and upload requirements; validate attachment listing. |

**Unverified transport recipes:** Cloud `/wiki` paths must not be copied onto an on-prem context path. Cloud v2 page IDs/space IDs and Server/DC space keys differ; content representations vary across APIs. An append is an **update**, not an independent insert: read current storage/version, convert the new material, preview the concatenation and diff, check that the version has not changed, PUT with version + 1, then verify the entire page. Never concatenate untrusted Markdown directly into storage XML. Escape text and attributes (especially links/URLs), validate URL schemes, and safely handle fenced-code delimiters including `]]>` in CDATA; do not trust a converter merely because it renders headings (e.g. blue H3), formatting, lists, tables or `ac:structured-macro` code blocks. When a converter cannot round-trip a page safely, preserve the source and request human intervention rather than stripping macros or overwriting rich content. Never log private page bodies or credentials.

**Manual fallback:** draft a page title, parent, space, paste-ready rendered content, link/attachment list and formatting review checklist for a human editor. For a scenario-only test plan using the Generic reference format, do not mix analysis, risk or other report sections into the page: use an H3 `Test Scenario 01 — <title>` heading (blue `rgb(0,82,204)` in the rendered Confluence page), bold GIVEN/WHEN/THEN/AND on separate lines with a blank evidence placeholder after each, relevant CLI/SQL/API snippets in code blocks after the corresponding THEN/AND, and Result/Status (`PASS`/`FAIL`/`BLOCKED`)/Notes only at the end. Verify rich formatting in Confluence rather than assuming pasted Markdown preserves colour or code blocks. Mark **unverified / not published**; only an authorized read-back of the resulting page can verify it.

## Transport prerequisites and format conversion

**MCP:** Prefer an approved Confluence tool supporting the *confirmed* Cloud or Server/DC deployment. Read space/page/version and rendered content through the same tenant after a write; do not assume `get_page`, `update_page` or converter tools exist. **REST:** `$BASE` is a trusted configured URL: Cloud normally includes the `/wiki` context; Server/DC uses the configured on-prem context path without copying Cloud's `/wiki`. Curl's `-H "@$AUTH_HEADER_FILE"` reads a permission-restricted header file provisioned by an approved secret store outside the repository; only its path, not its contents, enters process argv. PowerShell `$Headers` is an approved in-memory authentication header dictionary; never put secrets in command history/logs. Examples are **unverified** until exercised with approved permissions. Encode titles, paths and query values, and keep reviewed `approved-*.json` request files out of source control.

**L0 deployment check:** an `*.atlassian.net` hostname suggests Cloud, but a custom hostname or proxy is ambiguous. Use a read-only configured Atlassian `serverInfo` capability if exposed, plus Confluence site/space API response or administrator confirmation to establish product and edition before choosing `/wiki/api/v2` versus Server/DC `/rest/api/content`. If the capability is unavailable, use pasted/manual input rather than probing another host. No page creation/update without L4 approval.

The Generic Server/DC converter treats Markdown headings (including blue H3), bold/italic, inline code, links, fenced code as `ac:structured-macro`, lists, tables, rules and paragraphs. That is *not* a guarantee of faithful round-trip conversion. Escape XML text/attributes and URLs; reject unsafe URL schemes, escape literal storage markup, and safely split or avoid `]]>` inside CDATA code blocks. Preview rendered Confluence storage, compare it to the source, and preserve existing macros/attachments. Never submit raw untrusted Markdown as `body.storage`; never silently append to or replace an existing page.

### Confluence Cloud: read and search

For v2, read a known page ID with `body-format=storage`, fetch its version and rendered body; list/search within the confirmed space using v2 pagination links or v1 CQL only if the tenant supports it. Cloud v2 space **ID** differs from a space key. Some rich-content and attachment operations still use Cloud v1; check capability before changing routes.

```text
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" -H "Accept: application/json" "$BASE/api/v2/pages/12345?body-format=storage"
Invoke-RestMethod -Method Get -Uri "$Base/api/v2/pages/12345?body-format=storage" -Headers $Headers -ErrorAction Stop
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" "$BASE/api/v2/spaces/67890/pages?limit=25"
Invoke-RestMethod -Method Get -Uri "$Base/api/v2/spaces/67890/pages?limit=25" -Headers $Headers -ErrorAction Stop
```

Follow returned cursor `_links.next`/`Link` rather than inventing offsets. If using Cloud v1 CQL, use `$BASE/rest/api/content/search?cql=<encoded-space-scoped-query>&limit=25` and inspect the tenant's continuation links.

### Confluence Cloud: create, update, append and verify

Confirm target parent/space ID and approved representation, preview the rendered page, then send a reviewed JSON request to v2 pages. For update/append, re-fetch current content/version and compare against the snapshot; the JSON must include the supported body representation and version number incremented by one. For append, concatenate **converted** new content with current storage only after a diff/approval; stale versions must stop. Re-fetch the page and compare title, body, parent and version after any write.

```text
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-page.json "$BASE/api/v2/pages"
Invoke-RestMethod -Method Post -Uri "$Base/api/v2/pages" -Headers $Headers -ContentType "application/json" -InFile "approved-page.json" -ErrorAction Stop
curl --fail-with-body --silent --show-error -X PUT -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-update.json "$BASE/api/v2/pages/12345"
Invoke-RestMethod -Method Put -Uri "$Base/api/v2/pages/12345" -Headers $Headers -ContentType "application/json" -InFile "approved-update.json" -ErrorAction Stop
```

Attachment support depends on edition/API: discover upload endpoint, content type, size limits and permissions, then verify the attachment listing; do not reuse a page JSON PUT as a multipart upload.

### Confluence Server/Data Center: read and find by title

The pinned Generic Server/DC tool first resolves `spaceKey` plus exact title and expands version/space; for a known ID it reads storage, version, space and ancestors. Confirm a unique title match and correct parent before any mutation.

```text
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" "$BASE/rest/api/content?spaceKey=QA&title=Approved%20Plan&expand=version,space"
Invoke-RestMethod -Method Get -Uri "$Base/rest/api/content?spaceKey=QA&title=Approved%20Plan&expand=version,space" -Headers $Headers -ErrorAction Stop
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" "$BASE/rest/api/content/12345?expand=body.storage,version,space,ancestors"
Invoke-RestMethod -Method Get -Uri "$Base/rest/api/content/12345?expand=body.storage,version,space,ancestors" -Headers $Headers -ErrorAction Stop
```

For larger result sets, use scoped CQL and paginate using returned `_links.next` or supported start/limit semantics. Treat 403/404 distinctly; neither proves the page does not exist.

### Confluence Server/Data Center: create, update, append and verify

For create, POST `type: page`, `title`, `space.key`, optional ancestors and converted `body.storage` (`representation: storage`). For update/append, fetch the complete current storage and version, verify expected parent/title, safely convert additions, preview old/new storage, then PUT `type: page`, title, body.storage and **current version + 1**. A stale version must block publication. Verify ID/version and rendered page after the write; a successful converter or PUT alone is not verified publication.

```text
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-page.json "$BASE/rest/api/content"
Invoke-RestMethod -Method Post -Uri "$Base/rest/api/content" -Headers $Headers -ContentType "application/json" -InFile "approved-page.json" -ErrorAction Stop
curl --fail-with-body --silent --show-error -X PUT -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-update.json "$BASE/rest/api/content/12345"
Invoke-RestMethod -Method Put -Uri "$Base/rest/api/content/12345" -Headers $Headers -ContentType "application/json" -InFile "approved-update.json" -ErrorAction Stop
```

Attachments use instance-specific multipart endpoints; review approved files and verify IDs, not just a 2xx response. **Manual-only variant:** unsupported Cloud/Server representation, conversion loss, unavailable approved auth or inability to preserve macros → hand off the draft with `status: unverified / not published`, exact human formatting and read-back steps.
