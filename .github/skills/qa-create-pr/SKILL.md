---
name: qa-create-pr
description: Draft a project-convention-compliant QA pull request from the remote branch comparison; request exact approval before any push or PR creation.
argument-hint: "[source branch, base branch, work item or work ID]"
user-invocable: true
---

# Create a QA pull request

## 1. Trigger and scope

Invoke directly to prepare a PR for a confirmed branch containing QA work. Draft-only: this skill never merges, deploys, changes reviewers' readiness or silently commits. No preceding skill is required.

## 2. Inputs

- Use a supplied source branch without rediscovering it; otherwise inspect the current branch. Reject detached HEAD, missing local source, or source equal to base.
- Resolve base and remote from approved `.github/ai-qa/project/project.md` and `conventions/*.md`, then repository metadata. Do not default silently to `main` or `origin`; ask if competing bases exist.
- Resolve ticket/user-facing intent via configured provider, pasted ticket, or `qa-work/<work-id>/index.md`. A work ID need not be a Jira key. Confirm any missing intent; do not invent business outcomes.
- Determine PR hosting transport, template, title conventions and review state from project configuration and actual repository evidence.

## 3. Context and prerequisites

Read `.github/ai-qa/framework/method/safety.md`, `discovery.md`, `artefacts.md` and `.github/ai-qa/project/project.md` before operation. Consult named `.github/ai-qa/project/conventions/git.md`, `testing.md`, `qa-process.md`, `integrations.md` and `reporting.md` when present, then other approved `conventions/*.md`; never treat a missing convention as an installed project rule. Read the applicable provider recipe and `.github/PULL_REQUEST_TEMPLATE.md` or actual project template, plus any available example/contributing rules. Check whether there is already a PR for this head/base. Recheck ticket revision, source/base remote refs, index provenance, current branch/commit and configured conventions before reusing a prior draft; if any changed, regenerate title/body and reconfirm approvals. Do not include local uncommitted changes as if they will appear in the PR.

## 4. Procedure

1. Confirm the source branch exists locally and its remote-tracking ref is available. Use a three-dot merge-base comparison between actual remote refs (for example `git diff --name-status <remote>/<base>...<remote>/<source>`) so the inventory matches the PR Files changed view. Begin with `--name-status`; expand to `--stat`, branch-only commit subjects or patch only if needed. If refs are absent, ask before using local comparisons or pushing/fetching.
2. Derive the short user-facing summary from ticket intent, not the diff. Select title type/scope/ticket format from the project's approved convention. Compare branch prefix with actual change category (e.g. feat/fix/chore, if supported); show current and proposed prefix/type in plain chat and explicitly confirm the choice even when unchanged. Do not rename the branch silently.
3. Fill the actual PR template. For at most five changed files **or** fewer than 50 changed lines (excluding generated lockfiles), cap Summary at two sentences; otherwise at four. Base List of Changes on the comparison, with concise **bold area** bullets. Include relevant work/requirement IDs, observed test commands/results, known gaps and risks. A commit is not evidence of release, test PASS or completed ticket scope.
4. Show the **exact title** and **raw Markdown body** in chat (no fence, table or wrapper around the body), along with head/base, destination, draft status and whether a push is needed. Ask for explicit approval of the type, exact title/body, target and PR creation. If anything changes, show the new body and ask again. Push needs its own separate L4 approval.
5. After approval, use configured provider operations. For GitHub, prefer approved GitHub-native tools; when `gh` is configured use `gh pr create --draft --base <base> --head <source> --title <title> --body-file -` and pass the exact approved Markdown on standard input, avoiding a body file entirely. For Azure Repos use authorised `az repos pr create --draft` with supported description input or equivalent provider operation; do not assume GitHub options apply to `az` or interpolate an untrusted description into a shell command. If neither can pass the approved content safely, return a manual, copy-ready draft and verification instructions, **not created**.
6. Verify returned PR ID, URL, title, head/base, draft state and body using an authorised read-back. If a PR already exists for head/base, return its URL rather than creating another; do not overwrite its content without a separate preview and approval. A timeout is unverified, not permission to blindly retry.

## 5. Safety gates

Local commits and branch changes require separate **L2** approval; pushes and PR creation require independent **L4** approvals for their exact scope. No implicit commit, force push, ready-for-review, merge or deployment. Avoid a body-file altogether; never leave a transient PR body in the target project or include it in a work output. Redact secrets and unwanted mentions. Do not hard-code a host, Jira integration, template path, title grammar or default branch.

## 6. Outputs and evidence
Requested saved PR receipts need YAML frontmatter `work-id`, `skill: qa-create-pr`, `framework-version` (installed or `unknown`), `created` (UTC ISO) and `inputs` (ticket/branch/PR artefact refs and revisions). Standalone local `index.md` updates need no extra gate; orchestrated writes follow L1 plan approval, distinct from gated PR creation L4.


Present proposed/created PR title and body, head/base and revision, included file/commit inventory, test evidence with pass/fail/not-run distinctions, confirmed prefix/type, approvals, draft state and verified URL/ID. If not approved, no transport, missing refs or read-back failure, clearly state **DRAFT**, **BLOCKED** or **UNVERIFIED**, never "created". If authorised to persist a work record, update `qa-work/<work-id>/index.md` and a report in its `outputs/` with frontmatter recording work ID, source revisions, commit, generated time, provenance and link; leave existing approved records intact and mark stale drafts.

## 7. Standalone and handoff
Resolve work ID from explicit ID, then a branch ticket per confirmed `.github/ai-qa/project/conventions/git.md` if present, else `adhoc-YYYYMMDD-<safe-slug>` (not a real issue). With no prior artefact gather minimal intent/branch/test evidence. On ticket/config/branch drift regenerate draft and reconfirm approvals; suggest `qa-configure refresh` for project-layer updates, never edit it.


Discover the branch, intent and template independently when no prior QA steps ran. Suggest `qa-run-tests` for missing execution evidence or `qa-publish` for separately approved reporting. Creating a PR never implies publication to another tracker.
