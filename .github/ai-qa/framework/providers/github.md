# GitHub — transport recipe

Use the [provider contract](operations.md). Confirm owner/repository, issue versus pull request versus Discussions, visibility, labels, write permission and destination before fetching private content or publishing. Prefer approved GitHub-native tools; use REST/GraphQL or `gh` only when configured and authorized.

| Named operation | MCP hint | CLI | REST and verification | Manual |
|---|---|---|---|---|
| L0 `workitem.get` / `workitem.search` | Approved issue get/scoped search | `gh issue view` / `gh issue list` if authenticated | Issues get/search; normalize title, body, AC if present, type, state, links, comments, updated | Pasted issue/query results, unverified |
| L4 `workitem.comment` / `workitem.create` | Approved comment/create issue | `gh issue comment` / `gh issue create` if approved | Issue comment/issue POST; GET exact result | Paste-ready issue/comment in `outputs/`, unverified |
| L0 `repo.pr.list` / L4 `repo.pr.create` | Approved PR list/create | `gh pr list` / `gh pr create` | PR list/POST then GET returned head/base | Paste-ready PR in `outputs/`, unverified |
| L0 `repo.branch-protection` | Approved repository settings/rules read, if exposed | `gh api` (see below) | Classic protection and branch rules endpoints (see below) | Pasted settings screenshot or text, unverified |
| L0 `ci.runs` / `ci.run.get` | Approved Actions run list/detail | `gh run list` / `gh run view` | Actions workflow-runs list/GET specific run, paginate | Human run URL/detail, unverified |
| L0 `ci.test-results` | Approved check/artifact results tool | `gh run view` checks/jobs, artifacts if approved | Check runs/artifacts only if actual test result report can be read | Exported test report with provenance, unverified |

| Operation | Example transport (capability-dependent) |
|---|---|
| Get | `GET /repos/{owner}/{repo}/issues/{number}` for issue metadata; PRs also appear as issues, so confirm type and fetch PR endpoint when needed. |
| Search/list | Repository-scoped issues/PR search with bounded pages; verify query syntax, authorization and pagination. |
| Create/update issue | `POST /repos/{owner}/{repo}/issues`, `PATCH /repos/{owner}/{repo}/issues/{number}`; check labels/assignees exist and re-fetch. |
| Comment | `POST /repos/{owner}/{repo}/issues/{number}/comments`; a comment on a PR is not the same as a line review comment. |
| PR | Create only from a confirmed existing branch and base with approval; diff/review and verify PR number, head/base and URL afterward. |
| Wiki | GitHub Wiki is a separate Git repository and may be disabled. Do not mistake it for a repo Markdown file or GitHub Discussions. |

On write, preview exact Markdown, external links and mentions: mentions can notify people. Avoid duplicate posts by searching for an already-created target and storing the returned canonical ID; never blindly retry a timed-out POST. The endpoint recipe is **unverified** until an authorized read-back confirms content and visibility. With no approved transport, provide a paste-ready draft, chosen issue/PR destination and human verification checklist labeled **unverified / not published**.

## Transport selection

**MCP:** Use an approved GitHub tool whose repository scope and read/write capability are confirmed. Issue search, PR reviews, discussions and wiki Git repositories are distinct capabilities; no tool name is implied. **REST:** `$API` is the configured trusted GitHub REST origin (for github.com: `https://api.github.com`; for Enterprise Server: its documented `/api/v3` origin), `$OWNER`/`$REPO` are confirmed and URI-safe. Curl `-H "@$AUTH_HEADER_FILE"` reads a permission-restricted approved secret-store header file outside the repo (path, not token, in process argv); PowerShell `$Headers` is in-memory. Set `Accept: application/vnd.github+json` and a supported `X-GitHub-Api-Version` where applicable; inspect GHES API compatibility first. Recipes are **unverified** until exercised with approved permission. Never transmit a private issue body to an unrelated repository.

### Read and scoped search/list

GET an issue by number; if it has a `pull_request` field, GET `/pulls/{number}` for PR-only fields. A repository issues list can include PRs, so filter type explicitly. Search bounded pages with encoded `repo:{owner}/{repo}` and `is:issue` or `is:pr`; honor `Link: rel="next"` and incomplete-result indicators. For a known issue:

```text
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" -H "Accept: application/vnd.github+json" "$API/repos/$OWNER/$REPO/issues/123"
Invoke-RestMethod -Method Get -Uri "$Api/repos/$Owner/$Repo/issues/123" -Headers $Headers -ErrorAction Stop
curl --fail-with-body --silent --show-error -H "@$AUTH_HEADER_FILE" -H "Accept: application/vnd.github+json" "$API/repos/$OWNER/$REPO/issues?state=open&per_page=30&page=1"
Invoke-RestMethod -Method Get -Uri "$Api/repos/$Owner/$Repo/issues?state=open&per_page=30&page=1" -Headers $Headers -ErrorAction Stop
```

PowerShell double-quoted URI interpolation can treat `?` following a variable unexpectedly; construct and inspect the final encoded URI before invoking. For search, use `/search/issues?q=<encoded-repo-scoped-query>&per_page=30&page=1`; GitHub search result caps can prevent exhaustive inventory.

### Create/update issue, comment, link and verify

Preview repository, title/body, labels/assignees and mentions before approval. POST a reviewed JSON issue/comment body, or PATCH an existing issue; search for a duplicate after any timeout rather than repeating POST. Labels must exist or be authorized to create; issue association and references must be verified after publishing. Re-fetch issue/comment ID and compare visible body. Link references in body/comments are not necessarily formal cross-repository issue links.

```text
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Accept: application/vnd.github+json" -H "Content-Type: application/json" --data-binary @approved-issue.json "$API/repos/$OWNER/$REPO/issues"
Invoke-RestMethod -Method Post -Uri "$Api/repos/$Owner/$Repo/issues" -Headers $Headers -ContentType "application/json" -InFile "approved-issue.json" -ErrorAction Stop
curl --fail-with-body --silent --show-error -X PATCH -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-update.json "$API/repos/$OWNER/$REPO/issues/123"
Invoke-RestMethod -Method Patch -Uri "$Api/repos/$Owner/$Repo/issues/123" -Headers $Headers -ContentType "application/json" -InFile "approved-update.json" -ErrorAction Stop
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-comment.json "$API/repos/$OWNER/$REPO/issues/123/comments"
Invoke-RestMethod -Method Post -Uri "$Api/repos/$Owner/$Repo/issues/123/comments" -Headers $Headers -ContentType "application/json" -InFile "approved-comment.json" -ErrorAction Stop
```

### Pull requests, Wiki and manual-only variants

For a PR, first verify distinct existing head/base branches, diff and requested reviewers. POST approved JSON to `/repos/{owner}/{repo}/pulls`, then GET returned PR number and compare head/base/content. Do not create a branch or PR as a side effect of a read-only request. GitHub Wiki uses a separate Git repository and may be disabled; REST Issues endpoints do **not** publish Wiki pages. If no approved Git transport or tool exists, supply Markdown/manual steps and label `unverified / not published`. For private assets/attachments, use only the provider's supported approved mechanism; never assume an issue can accept arbitrary binary upload via JSON.

```text
curl --fail-with-body --silent --show-error -X POST -H "@$AUTH_HEADER_FILE" -H "Content-Type: application/json" --data-binary @approved-pr.json "$API/repos/$OWNER/$REPO/pulls"
Invoke-RestMethod -Method Post -Uri "$Api/repos/$Owner/$Repo/pulls" -Headers $Headers -ContentType "application/json" -InFile "approved-pr.json" -ErrorAction Stop
```

**Manual variant:** paste-ready issue/PR text, repository and intended issue/PR type, existing head/base if PR, required label checks and steps for a human to record actual URL/ID. `status: unverified` until read-back; no fabricated IDs.

## GitHub PRs and Actions: MCP → `gh` CLI → manual

Use an approved GitHub MCP tool only for the exact confirmed repository/operation. If GitHub CLI is already authenticated to the correct `github.com` or Enterprise host, read a PR with `gh pr view <number> --repo <owner>/<repo> --json number,url,title,headRefName,baseRefName`; list with `gh pr list --repo <owner>/<repo> --limit 30`. After previewing the diff and obtaining L4 approval, `gh pr create --repo <owner>/<repo> --head <existing-head> --base <confirmed-base> --title <approved-title> --body-file <approved-body-file>` is an **unverified** CLI recipe; re-read the returned PR. Never automatically merge or request review. Do not pass private body text on the command line; use a protected reviewed body file outside the reusable framework.

For Actions, first read `gh workflow list --repo <owner>/<repo>` and `gh run view <run-id> --repo <owner>/<repo> --json status,conclusion,url` if permission allows. Triggering `gh workflow run <workflow-file> --ref <approved-ref> --repo <owner>/<repo>` may deploy or incur cost: inspect workflow inputs/side effects, obtain separate L4 approval, then read the new run and eventually its conclusion; queued/in-progress is not success. Workflows may be disabled or inaccessible. MCP/CLI failure → manual handoff in approved `qa-work/<id>/outputs/` with repo, branch, workflow or PR fields and human read-back steps, labeled `unverified / not created/not run`; do not fabricate URLs.

```text
gh pr view <number> --repo <owner>/<repo> --json number,url,title,headRefName,baseRefName
gh run view <run-id> --repo <owner>/<repo> --json status,conclusion,url
```

### Branch protection (`repo.branch-protection`, L0)

Read-only; run both checks for the confirmed base branch, because rulesets (repository or organization) are separate from classic protection. **Unverified** until exercised with the available permission.

```text
gh api repos/<owner>/<repo>/branches/<base>/protection
gh api repos/<owner>/<repo>/rules/branches/<base>
```

Classic protection: a 404 whose message is "Branch not protected" means `classic_protection: none`; a 403, or a 404 for another reason, means blocked, so report `blocked` with the reason. Rules: an empty array means `rules: none`; otherwise record the rule types. An organization ruleset appears here when it applies to the branch. Return `∅` only when both checks completed and found nothing. Never infer protection from a branch name.

For `ci.test-results`, green Actions conclusion alone does not establish test counts. Read an approved test-report artifact/check output actually linked to the run and report parsed passed/failed/skipped counts with artifact URL, or return `unsupported`/`unknown`; never invent counts. For `ci.runs`, `gh run list --repo <owner>/<repo> --limit 30` or the scoped Actions runs REST endpoint is a list operation distinct from `ci.run.get`.
