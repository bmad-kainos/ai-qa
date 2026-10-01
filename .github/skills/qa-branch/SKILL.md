---
name: qa-branch
description: Propose and safely create a task-specific QA branch following the repository's actual naming and base conventions.
argument-hint: "[ticket, task and optional base branch]"
user-invocable: true
---

# Prepare QA branch

## 1. Trigger and scope
Invoke directly when isolated QA work needs a branch. A name proposal is not automatically a checkout, commit or push. No prerequisite design skill is mandatory.

## 2. Inputs
Gather task/work ID (ticket optional), requested base and branch name if provided. Inspect current branch, HEAD, local/remote refs and working tree; if task context is missing ask rather than invent an issue. Read a current `qa-work/<work-id>/index.md` if present but do not trust a stale branch reference.

## 3. Context and prerequisites
Read `.github/ai-qa/framework/method/safety.md`, `discovery.md` and `artefacts.md`; `.github/ai-qa/project/project.md` and named `conventions/git.md` and `qa-process.md` if present, then other approved `conventions/*.md` (otherwise derive read-only session context), repository contributing/branch conventions and protected-branch policy. Verify actual default/base ref, tracking state and current branch; check for a matching local/remote branch and uncommitted changes. Resolve conflicting instructions rather than guessing a base.

## 4. Procedure
1. If already on the correct branch, reuse it. Otherwise propose a unique name in confirmed project style, including ticket key when required (for example `task/PROJ-123-add_auth_coverage`); if no project rule exists, propose a readable safe slug and ask for acceptance. Explain scope and selected base. Do not impose example POC naming rules over the project's conventions.
2. Present the exact proposed name, base SHA, effects (fetch, checkout, new branch) and clean/dirty status. Obtain action-specific **L2** confirmation before branch creation/checkout. A user-approved branch name is not approval to discard or stash changes.
3. On approval, verify the base is current per project conventions; create/switch without resetting or discarding changes, then verify branch/ref and unchanged worktree content. On conflict or missing remote stop and offer safe alternatives.
4. Report whether it exists only locally or was separately pushed with **L4** approval. No dependency installation unless independently approved at **L5**. Recheck branch/work index freshness before subsequent automation.

## 5. Safety gates
Require **L2** approval for creation/checkout and separate **L4** approval for any push. Never force checkout, stash/drop/reset changes, delete or overwrite an existing branch, or assume `main`. Stop on uncommitted changes or conflicting names and offer safe options. No deployment-specific logic belongs here.

## 6. Outputs and evidence
Requested saved branch notes need YAML frontmatter `work-id`, `skill: qa-branch`, `framework-version` (installed or `unknown`), `created` (UTC ISO) and `inputs` (task/source/branch refs and revisions). Standalone local index updates need no extra L1 gate; orchestrated work follows L1 plan approval. Branch creation always needs separate L2 approval.

Return branch name, base SHA, working-tree status, creation/reuse, L2 decision and local/remote state; if blocked, explain why no switch occurred. If separately authorised to maintain `qa-work/<work-id>/index.md`, record source revision, branch/commit, action/approval/time and status; do not create an index solely to justify branch creation. Any saved output uses frontmatter with provenance and must stay outside `.github/ai-qa/project/`.

## 7. Standalone and handoff
Resolve work ID from explicit ID, existing branch ticket per confirmed `.github/ai-qa/project/conventions/git.md` if present, else `adhoc-YYYYMMDD-<safe-slug>` (not an issue key). If no prior artefact exists gather minimal task/base/naming conventions. On source/config/branch drift reconfirm name/base and suggest `qa-configure refresh` for project-layer changes; never edit it here.

Discover conventions and task context independently. Offer `qa-generate-tests` or `qa-create-pr` as next steps; do not run them implicitly.
