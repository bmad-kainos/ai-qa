# Azure DevOps Wiki — transport recipe

Use the [provider contract](README.md). Azure Wiki is not Azure Boards: determine organization, project, wiki identifier, page path, supported API version and whether it is a project wiki or a published code wiki. A published code wiki is backed by Git; do not assume REST page updates are allowed.

| Named operation | MCP hint | CLI | REST and verification | Manual |
|---|---|---|---|---|
| L0 `docs.search` | Approved Wiki page enumeration/search, scoped to wiki | `az devops wiki page` capabilities if installed; no assumed full-text search | Wiki/page enumeration if supported, bounded; unsupported search is not an empty result | Human page list with paths in `outputs/`, unverified |
| L0 `docs.get` | Approved page read with content and ETag | `az devops wiki page show` | GET exact wiki/path with content and ETag | Pasted Markdown with source path, unverified |
| L4 `docs.publish` `create` | Approved project-wiki create | `az devops wiki page create` if supported | Project-wiki PUT with approved body; read back | Paste-ready page in `outputs/`, not published |
| L4 `docs.publish` `update`/`append` | Approved version-aware update | `az devops wiki page update` if supported | Fresh GET, diff/append, conditional PUT with ETag; read back | Human diff in `outputs/`, not published |

- **Read/list:** approved Wiki tool or Services REST `GET https://dev.azure.com/{org}/{project}/_apis/wiki/wikis/{wiki}/pages?path={encoded-path}&includeContent=true&api-version=<supported-version>`; inspect canonical path, ETag and content. Page search/list capability depends on instance.
- **Create/update:** for a writable project wiki only, preview escaped Markdown and links. Use documented PUT pages operation, `Content-Type: application/json`, body with `content`, and `If-Match` with the previously observed ETag on updates. Reject conflicts; re-read exact path and compare. For a code wiki, propose a repository change/PR to the wiki source under its normal review workflow instead.
- **Assets:** verify link targets, attachment path and permitted image storage; do not silently copy binary assets or private documents.

Paths are case/encoding sensitive; URL-encode each query parameter and respect the configured Server/Services base URL and API version. **Unverified:** these examples are not evidence of access or publication. Without an approved writable transport, provide a paste-ready Markdown page with exact wiki/path, asset checklist and manual read-back instructions labeled **unverified / not published**.

## Deployment and tool selection

**MCP:** Use only an approved Wiki tool verified to support this project/wiki/page operation. Do not mistake an Azure Boards work-item tool for Wiki access. **REST:** Confirm Services versus Azure DevOps Server, project collection URL, supported API version and project wiki versus published code wiki before writing. `$BASE` is `https://dev.azure.com/{org}/{project}` on Services, or the configured Server collection/project path. `$WIKI` is a URI-encoded wiki ID/name, `$PAGE_PATH` a URI-encoded wiki path. Curl `-H "@$AUTH_HEADER_FILE"` reads a permission-restricted approved secret-store header file outside the repo, not a secret expanded in process argv; PowerShell `$Headers` is in-memory. Every example below is **unverified** until tested against the configured instance.

### Read and enumerate pages

Get by path with content and capture the response `ETag` header as well as JSON: some clients hide headers by default, so use `Invoke-WebRequest` for ETag or an approved tool that exposes it. Enumerate only supported wiki/page collections; a path query is not a full-text search guarantee. Follow returned continuation headers/links where supported and make incomplete results explicit.

```text
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" "$BASE/_apis/wiki/wikis/$WIKI/pages?path=$PAGE_PATH&includeContent=true&api-version=$API_VERSION"
Invoke-WebRequest -Method Get -Uri "$Base/_apis/wiki/wikis/$Wiki/pages?path=$PagePath&includeContent=true&api-version=$ApiVersion" -Headers $Headers -ErrorAction Stop
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" "$BASE/_apis/wiki/wikis?api-version=$API_VERSION"
Invoke-RestMethod -Method Get -Uri "$Base/_apis/wiki/wikis?api-version=$ApiVersion" -Headers $Headers -ErrorAction Stop
```

Use the approved tool or `Invoke-WebRequest` response object to capture ETag without persisting sensitive headers; plain `curl` body output does not expose the ETag and is insufficient alone for an update. Never send auth headers across redirects to another host.

### Project wiki create/update/verify

Preview destination path and rendered Markdown, approve externally visible content/mentions and confirm project wiki is writable. PUT a reviewed JSON body containing `content` to the pages route. On update supply `If-Match: <observed ETag>` (PowerShell `$WriteHeaders` includes approved auth plus current `If-Match`) and stop on HTTP 412; never use `*` to bypass concurrency. Re-read exact path and compare content/ETag. For a code wiki, use a reviewed Git change/PR instead; REST PUT is **unsupported** for that mode unless instance capability explicitly permits it.

```text
curl --fail-with-body --silent --show-error -X PUT -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" -H "If-Match: $ETAG" --data-binary @approved-page.json "$BASE/_apis/wiki/wikis/$WIKI/pages?path=$PAGE_PATH&api-version=$API_VERSION"
Invoke-RestMethod -Method Put -Uri "$Base/_apis/wiki/wikis/$Wiki/pages?path=$PagePath&api-version=$ApiVersion" -Headers $WriteHeaders -ContentType "application/json" -InFile "approved-page.json" -ErrorAction Stop
```

For creation, follow the provider's required conditional header for missing pages rather than reusing a stale update ETag. For assets, validate target paths and use the wiki's documented attachment/version-control workflow; do not embed private binaries. **Manual fallback:** exact wiki/page path, paste-ready Markdown, asset checklist and human verification steps; mark `unverified / not published`, no fabricated page ID.

## `az` CLI and manual transports

If the Azure DevOps CLI extension is already installed and authenticated, check edition and `az devops wiki page --help` before using these **unverified** command shapes. A project wiki can be read with `az devops wiki page show --wiki <wiki> --path <page-path> --organization <org-url> --project <project> --output json`; read back after any approved write. `az devops wiki page create` and `az devops wiki page update` require the exact confirmed `--wiki`, `--path`, `--content` and (for updates when supported) version; inspect CLI help and current page revision before L4 approval. Putting sensitive page content in CLI flags leaks into shell history/process lists: use approved protected REST/file transport or manual handoff instead. Do not use CLI writes for a published code wiki unless its capabilities are explicitly confirmed.

```text
az devops wiki page show --wiki <wiki> --path <page-path> --organization <org-url> --project <project> --output json
```

If MCP, CLI and REST are unsupported or fail, preserve proposed Markdown under approved `qa-work/<id>/outputs/` with the target wiki/path, evidence and paste/verification instructions. Mark `unverified / not published`; a rendered draft is not a remotely created page.
