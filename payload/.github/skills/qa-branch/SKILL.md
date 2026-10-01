---
name: qa-branch
description: Propose a branch from confirmed repository conventions, create it locally after L2 approval, and treat push as a separate L4 action.
argument-hint: "[task/work-id and optional proposed base or branch name]"
---

# Prepare branch
Resolve and validate a branch proposal from this repository's recorded conventions. The proposal has no side effect; local creation is a separate gated action, and pushing is always separate.

## When to use
Use when QA work needs an isolated branch or when validating a proposed branch against project rules. Do not use as implicit approval to commit, push, create a PR, merge, discard work or edit project conventions.

## Reads
Always read `.github/ai-qa/project/project.md` for project/repository identity and source context; read `.github/ai-qa/project/conventions/git.md` sections `Remote host`, `Base branch`, `Protected branches`, `Branch patterns`, `Ticket syntax`, and related PR/commit conventions, plus `conventions/qa-process.md` `Team options` for an optional branch-description length rule. Read `.github/ai-qa/framework/method/{safety,discovery,artefacts,git}.md`, repository contributing guidance and current `qa-work/<work-id>/index.md` if present. Inspect actual branch, HEAD, refs and dirty state. If project configuration is missing, use read-only repository evidence; for missing values only, consult `.github/ai-qa/framework/defaults/git.md`, mark each chosen fallback `★ Default`, and suggest `qa-configure`. Never hard-code a branch or base name.

## Work-id
Resolve per `.github/ai-qa/framework/method/git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs
Take task/work ID, optional requested name/base and whether the user is asking only for a proposal or authorising local creation. Gather current branch, base/default branch, protected branches, branch/ticket patterns, remote, matching existing refs and dirty-tree state. If task or naming cannot be resolved, state the evidence gap and offer a convention-compliant proposal; never invent a ticket key.

## Procedure
1. Read the project's `Base branch`, `Protected branches`, `Branch patterns` and `Ticket syntax` exactly. Check whether an optional branch-description length appears under `qa-process.md` `Team options`; apply it only when configured. Validate ticket syntax and pattern together. Never assume or hard-code branch, base, ticket, team or remote names.
2. If a required convention is absent, use only the corresponding rule in `.github/ai-qa/framework/defaults/git.md`, label it `★ Default`, and include that provenance in the proposal. Project conventions and observed repository evidence take precedence over defaults; record conflicts rather than silently resolving them.
3. Inspect current branch/HEAD, base ref/SHA, local and remote candidate refs, protected status and worktree. If already on the requested valid branch, propose reuse. Otherwise propose a unique name consistent with the confirmed pattern, ticket syntax and optional description length. Show branch name, base and SHA, ticket match, evidence/defaults, dirty state, conflicts, and exact planned effects.
4. **Proposal mode has no side effect.** Return the proposal and wait for an explicit request/affirmative before creating. For creation, present the exact action and target, base, commands/effects and how existing changes are preserved, then obtain explicit L2 approval. Do not treat a request to propose as permission to create.
5. After L2 approval, create/switch to the local branch without resetting, cleaning, stashing or discarding any changes. Never force checkout, overwrite/delete an existing branch or modify protected/default branches. A dirty worktree is preserved exactly; if the branch operation cannot proceed without affecting it, stop and offer safe choices. Verify branch name, base relationship, refs and unchanged user work, then report the local outcome.
6. **Never push on create.** If the user later requests a push, show the exact remote and branch plus effects and get a separate L4 approval. After an authorised push, report its result; do not merge. Recheck branch and work-item freshness before later automation.

## Output
Present the proposal in chat. When creation is approved, write the step result to `qa-work/<work-id>/execution.md` and update `qa-work/<work-id>/index.md` with current/base refs, branch name, dirty state, `★ Default` choices, L2 approval, local outcome and push state (`not pushed` unless separately approved). Use:

```yaml
---
work-id: "<work-id>"
skill: "qa-branch"
framework-version: "<installed-version-or-unknown>"
created: "<UTC-ISO-8601>"
inputs:
	- source: "<task/conventions/git/repository path or link>"
		revision: "<commit/document revision/observed time>"
---
```

Report: proposed/created/reused branch; validated pattern/ticket syntax; base name and SHA; protected/default status; dirty-tree handling; defaults used; L2 decision; remote state; and blockers. Do not create an index only to justify a branch proposal; if no branch was created and persistence was not requested, no artefact write is needed.

## Side effects and safety
| Action | Level | Gate |
|---|---:|---|
| Inspect branch, refs, conventions and worktree | L0 | None |
| Propose a branch name/base | L0 | No side effect or gate |
| Create/switch to a local branch | L2 | Always preview exact branch, base, dirty state and effects; explicit affirmative required |
| Push a branch | L4 | Separate exact remote/branch preview and explicit affirmative required |
| Commit, merge, delete branch or change project conventions | L2/L5 | Not implied or performed by this skill |

Never discard dirty work. Creating a branch never implies pushing it. Never edit `.github/ai-qa/project/**` or operate on a protected/default branch.

## Drift
If evidence contradicts project conventions or project.md, record it under Drift in the artefact and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**`.
