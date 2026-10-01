---
name: qa-create-pr
description: Create a reviewed draft pull request using the repository's confirmed git conventions and configured repository provider; use when asked to open a PR for an existing branch.
argument-hint: "[source branch, base branch, work item or work ID]"
user-invocable: true
---

# Create Draft Pull Request
Create a draft pull request for this repository using its confirmed branching strategy, template and ticket-backed summary rules. Use the configured repository provider; prefer the current repository context and avoid extra git or provider commands when they do not change the outcome.

## When to use
- Creating a new pull request for a confirmed feature or work branch
- Opening a draft PR with the repository's required formatting
- Using the repository's PR template, exemplar and work-item context

Do not use to merge, deploy, make a PR ready for review or silently commit or push. The skill is directly invocable; no preceding workflow is required.

## Reads
Always read `.github/ai-qa/project/project.md`; `.github/ai-qa/project/conventions/git.md` sections `Remote host`, `Base branch`, `Protected branches`, `Branch patterns`, `Ticket syntax`, `PR title pattern`, `PR types`, `Prefix-to-type mapping`, `PR templates`, `Exemplar PR` and `Draft and reviewer policy`; `conventions/integrations.md`, `qa-process.md` and `reporting.md`; `.github/ai-qa/framework/method/safety.md`, `git.md` and `artefacts.md`; `.github/ai-qa/framework/providers/operations.md` and the configured repository provider recipe; actual project PR template(s); and `assets/pr-example.md`. Discover GitHub templates at `.github/pull_request_template.md` or `.github/PULL_REQUEST_TEMPLATE/` and Azure Repos templates at `.azuredevops/pull_request_template.md` only as candidates; use paths actually recorded in `PR templates`. If a value is absent, consult `.github/ai-qa/framework/defaults/git.md` and label it as a framework default, not a project fact. Read prior index/drafts only while their source revisions remain current. If the project layer is missing, use read-only session evidence and suggest `qa-configure`.

## Work-id
Resolve per `.github/ai-qa/framework/method/work-id-and-git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs
Resolve the source branch, confirmed base, remote/repository, optional ticket/work item, reviewed diff, project template, exemplar, test evidence, requested scope, and any prior current QA artefact. If context is missing, gather the minimum yourself; never refuse. Do not include uncommitted local changes as if they were part of the PR.

## Procedure
### Required workflow
1. **Resolve the source branch**
	- If the user provides a branch name, use it.
	- Validate only that the provided branch exists locally. If it does not, ask the user to confirm the branch name before continuing.
	- Only get the current branch from the local repository, for example with `git branch --show-current`, when the user did not provide one.
	- If the result is empty, detached, or the confirmed base branch, stop and ask the user for the correct feature branch.

2. **Resolve the base branch and repository context**
	- Use the `Base branch` and `Remote host` values from confirmed project conventions. If missing, use `.github/ai-qa/framework/defaults/git.md` as a clearly marked candidate and ask the user to confirm; never assume `main` or another base.
	- Prefer the current repository context for provider commands.
	- Only inspect the git remote if the configured provider cannot infer the repository or the working directory is ambiguous.

3. **Read the repository pull request conventions**
	- Use `PR title pattern`, `PR types`, `Prefix-to-type mapping`, `PR templates`, `Exemplar PR`, and `Draft and reviewer policy` in `conventions/git.md` as the source of truth.
	- If a value is not recorded, use the matching candidate in `.github/ai-qa/framework/defaults/git.md`, mark it as a framework default and ask for confirmation where it affects the proposed PR.
	- Derive the title summary from the work item's intent and user-facing outcome, not from a recap of the code diff. Use the ticket wording before the trailing ticket reference when the confirmed title pattern requires it.
	- Derive the PR type from the confirmed prefix-to-type mapping. Include a scope or breaking marker only when the project's pattern allows it and the work item/diff supports it.

4. **Read the PR template and example**
	- Use the actual project template path(s) discovered and recorded in `PR templates`; check the GitHub `.github/pull_request_template.md`/`.github/PULL_REQUEST_TEMPLATE/` and Azure Repos `.azuredevops/pull_request_template.md` locations as applicable.
	- Use [assets/pr-example.md](assets/pr-example.md) to match tone, detail and formatting style; use the configured `Exemplar PR` where available.
	- If a required example or project template cannot be read, stop and resolve the path or checkout before drafting.

5. **Fetch the work-item details when applicable**
	- If the branch contains a key matching configured `Ticket syntax`, use the configured work-item provider operation `workitem.get` with that key.
	- If the provider is unavailable or lookup fails, disclose the failure and ask the user to confirm the key or paste the title and description; do not silently substitute a different provider.
	- If there is no recognisable ticket key, derive intent only from available user context and ask the user to confirm the intent before continuing.
	- Use the work-item title and description as the primary source for the PR title wording and Summary. Do not invent requirements or user-facing outcomes unsupported by the work item or diff.

6. **Analyse the branch changes relative to the base branch**
	- Compare the source branch with the base branch using the remote-tracking refs and the exact three-dot diff: `git diff origin/<base>...origin/<branch>` (substitute the confirmed remote name where it is not `origin`). This matches the PR comparison semantics and excludes local uncommitted changes.
	- If remote-tracking refs are unavailable, ask the user before falling back to a local branch comparison or fetching/pushing. A push is always a separate L4 gate handled by `qa-create-branch`; PR creation never pushes implicitly.
	- Start with a lightweight inventory such as `--name-status`. Use `git diff --stat origin/<base>...origin/<branch>` or branch-only commit subjects only when they materially improve the List of Changes. Fetch a full patch only if necessary.
	- Use the diff to derive the List of Changes and validate an optional scope. Do not use the diff as the primary source for Summary.

7. **Validate branch prefix suitability**
	- Extract the branch prefix and its mapped PR type from `Prefix-to-type mapping`.
	- Analyse the change category from the diff and work-item intent. Use only the project's confirmed `PR types` and mapping; if absent, use candidate values from framework defaults only after marking them as defaults.
	- If the prefix/type appears unsuitable, suggest the more appropriate configured prefix/type.
	- Show the current prefix/type and suggested prefix/type in plain chat. Ask the user to confirm whether to use the suggestion or proceed with the original. Do not proceed until the user explicitly confirms the choice, even if it is unchanged. Do not rename the branch silently.

8. **Build the PR title and body**
	- Follow the confirmed title pattern exactly; when using a framework default, identify it as such and obtain confirmation.
	- Keep the summary short, user-friendly and suitable for release notes, following the configured case and length rules.
	- Fill the actual PR template exactly. If no template was found, use the candidate **Summary** followed by **List of Changes**, clearly identified as a framework default.
	- Scale Summary to the size of the change: for small PRs (5 or fewer changed files or fewer than 50 changed lines, excluding generated lockfiles), keep Summary to 2 sentences maximum; for larger PRs, use up to 4 sentences.
	- Avoid using the full project title in Summary; use generic terms like “system” or “repository” where that keeps the summary clear.
	- If implementation covers only part of the work item, focus Summary on the user-facing outcome of the implemented part and avoid mentioning unimplemented parts. Do not claim the full work item is implemented.
	- Avoid unnecessarily bloated preambles; detailed notes belong in List of Changes. Summary must be suitable for a commit log and should not start with “This pull request” or similar phrasing.
	- Write List of Changes from the actual diff using short bullets with **bold area prefixes** such as **backend**, **frontend**, **docs**, **automation** or **copilot**, choosing prefixes appropriate to the changes.
	- Match the tone and bullet style of the example file and configured exemplar.
	- Include relevant work/requirement IDs, observed test commands/results, known gaps and risks. A commit is not evidence of release, test PASS or completed work-item scope.
	- If the user asks to omit or reword specific phrasing, apply that change before creation.

9. **Present the proposed PR title and body to the user in the response**
	- Show the exact title.
	- Show the exact PR body that will be used.
	- Output the PR body as raw Markdown only, exactly as it will be posted. Do not wrap it in code fences, quote blocks, tables or another formatting container.
	- Also state head/base, destination, draft status and whether a push would be needed. Do not show full command output yet; focus on the proposed title and body.
	- Ask the user to confirm the exact type, title, body, destination and PR creation. This is the L4 gate for `repo.pr.create`. Approval of the branch-prefix/type check alone is not approval to create the PR.

10. **Create the pull request as a draft and then open it**
	- First use configured `repo.pr.list` for the same head/base. If a matching PR exists, do not create another; return its existing link after verifying it.
	- Route creation through operation `repo.pr.create` and the provider/deployment/transport selected in `conventions/integrations.md`.
	- For GitHub, when the configured `gh` CLI transport is available and authorised, write the exact approved body to a temporary approved body file, then run `gh pr create --draft --title "[title]" --body-file "[body-file]" --base "[base]" --head "[branch]"`. Prefer `--body-file` to inline multiline `--body` to avoid shell escaping errors. Remove the temporary file after success.
	- For Azure Repos, use `az repos pr create --draft` with the supported `--description @<file>` form and confirmed project/repository/source/target flags. Do not assume GitHub options apply to `az` or place untrusted description text in a command string.
	- If the configured tool/CLI cannot safely pass the approved content, use the configured next transport. If no approved transport works, write the exact payload to `qa-work/<work-id>/outputs/` and give manual paste and verification instructions; state **not created**.
	- Open the returned PR URL only after creation and verification. Do not mark the PR ready for review.

11. **Return the draft PR link**
	- Include the actual PR URL in the final response and state clearly that the PR is a draft.
	- If no PR was created, return the existing URL or accurately label the outcome `DRAFT`, `BLOCKED` or `UNVERIFIED`.

### Command minimisation
- Do not rediscover the branch if the user already supplied it.
- Do not include local uncommitted changes in PR drafting; use remote-tracking refs for diff analysis by default.
- Do not parse the git remote unless the configured provider needs help identifying the repository.
- Do not fetch a full patch diff unless file-level changes or `--stat` are insufficient.
- Do not run both `git diff --name-status` and `git diff --stat` by default. Start with one and expand only as needed.
- Do not create browser-first PR flows. Create through the configured provider and open the returned URL afterward.

### Form Processing Workflow
Progress:
- [ ] Step 1: Resolve the source branch
- [ ] Step 2: Resolve the base branch and repository context
- [ ] Step 3: Read the repository pull request conventions
- [ ] Step 4: Read the PR template and example
- [ ] Step 5: Fetch the work-item details if applicable
- [ ] Step 6: Analyse the branch changes relative to the base branch
- [ ] Step 7: Validate branch prefix suitability
- [ ] Step 8: Build the PR title and body
- [ ] Step 9: Present the proposed PR title and body
- [ ] Step 10: Create the pull request as a draft and open it
- [ ] Step 11: Return the draft PR link

### Troubleshooting
- If the PR title or Summary format is unclear, reread the configured project PR conventions and template before drafting.
- If work-item lookup fails for a detected key, stop and ask the user to confirm the key or provide the work-item context.
- If the configured CLI needs multiline body content, write it to a temporary file and use `--body-file` or the provider's supported file-input form instead of inline Markdown.
- If a PR already exists for the same head and target, return that PR's link rather than attempting creation.

### Requirements
- Use operation `repo.pr.list` to search for an existing PR and `repo.pr.create` for creation, through the provider/deployment/transport configured in `conventions/integrations.md`.
- Use `conventions/git.md` as the source of truth for the title pattern, type, prefix mapping, base branch, draft/reviewer policy, PR templates and exemplar. Otherwise use `.github/ai-qa/framework/defaults/git.md` only as an explicitly marked framework default.
- Use the actual project template recorded under `PR templates`; inspect the discovered GitHub or Azure Repos location as applicable.
- Use `assets/pr-example.md` as the formatting reference.
- Base List of Changes on the actual GitHub-style diff between remote-tracking refs for source and base branches, using `git diff origin/<base>...origin/<branch>` (replace `origin` only with the confirmed remote name).
- Use `workitem.get` for ticket details when the branch contains a key matching configured ticket syntax. If lookup fails, stop and ask the user to confirm the key or provide its context.
- Create a draft PR only. Do not switch it to ready for review.
- Return the created PR link, or the existing PR link when one already exists for the same head and target.

## Output
Save a requested PR receipt under `qa-work/<work-id>/outputs/` with the frontmatter required by `.github/ai-qa/framework/method/artefacts.md`: `work-id`, `skill: qa-create-pr`, `framework-version`, `created` (UTC ISO-8601) and `inputs` (work item, branch, PR artefact references and revisions). Include proposed or created title/body, head/base and revisions, included file/commit inventory, test evidence, confirmed prefix/type, approvals, draft state, and verified URL/ID. If not approved, unavailable or not read back, label `DRAFT`, `BLOCKED` or `UNVERIFIED`, never `created`.

Update `qa-work/<work-id>/index.md` with the receipt link and PR status, and record the L4 gate action, target, exact payload/side effect, approver/time and resulting ID/URL. Preserve existing records and mark stale drafts when inputs change. Standalone index updates follow the L1 rules; orchestrated writes require workflow-plan approval.

### Standalone and handoff
Resolve work ID from explicit ID, then a branch ticket matching confirmed `.github/ai-qa/project/conventions/git.md`, else `adhoc-<yyyymmdd>-<slug>` (not a real issue). With no prior artefact gather minimal intent, branch and test evidence. On ticket/config/branch drift regenerate the draft and reconfirm approvals; suggest `qa-configure refresh` for project-layer updates, never edit the project layer. Discover branch, intent and template independently when no prior QA steps ran. Suggest `qa-run-tests` for missing execution evidence or `qa-publish` for separately approved reporting. Creating a PR never implies publication to another tracker.

## Side effects and safety
| Action | Level | Gate |
|---|---|---|
| Read branches, remote diff, work item, template and existing PR | L0 | No gate; use confirmed scope and bounded reads |
| Write local PR draft/receipt/index | L1 | Non-default branch; workflow-plan approval applies in orchestration; summarise changes |
| Create local branch or commit | L2 | Separate exact gate; not part of this skill's normal procedure |
| Push source branch via `qa-create-branch` | L4 | Separate gate with exact branch and side effects; never implied by PR approval |
| Create draft PR through `repo.pr.create` | L4 | Show exact title/body, head/base and side effect; explicit affirmative; verify by read-back |

No implicit commit, force push, ready-for-review, merge or deployment. Redact secrets and unwanted mentions. Do not hard-code a host, ticket provider, template path, title grammar or default branch.

## Drift
If evidence contradicts project conventions or project.md, record it under Drift in the artefact and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
