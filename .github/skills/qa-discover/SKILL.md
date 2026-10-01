---
name: qa-discover
description: "Gather read-only, sourced evidence about a repository's QA landscape and Project Context. Use for repository discovery or when an AI-QA skill needs current evidence."
argument-hint: "[repository, feature, ticket, or area]"
---

# QA Discover

Gather a proportionate, evidence-based view of the repository: what it contains, how it is built and tested, how changes are reviewed, and where requirements and operational context live. Never run the test suite. Discovery is read-only; it does not configure or repair project conventions.

## When to use

Use when starting QA work, changing repository scope, or establishing current evidence for another skill. It may be invoked alone or by `qa-configure`. Accept a repository, path, ticket, feature description, or current workspace; no ticket key or completed upstream skill is required. Do not use it to persistently adapt AI-QA; that is exclusively `qa-configure`. Do not require a Jira, Confluence, ADO, or GitHub integration when local files or supplied requirements suffice.

## Reads

Always read `.github/ai-qa/project/project.md` when present for the project summary, components, stack, environments, dependencies, constraints, docs and unknowns. Read applicable `conventions/git.md`, `testing.md`, `qa-process.md`, `integrations.md`, and `reporting.md` to understand current operating rules; read `conventions/discovery.md` if present as existing project evidence, never as authority to edit it. Read `.github/ai-qa/framework/method/{discovery,safety,precedence,work-id-and-git,artefacts}.md`. Read `.github/copilot-instructions.md` if present and only relevant prior `qa-work/<work-id>/` artefacts. If the project layer is missing, proceed from read-only session evidence, record that absence, and suggest `qa-configure` for persistent setup.

## Work-id

Resolve per `.github/ai-qa/framework/method/work-id-and-git.md`: explicit argument → ticket key from current branch via the `Ticket syntax`/`Branch patterns` in conventions/git.md → `adhoc-<yyyymmdd>-<slug>`.

## Inputs

Use the user's scope when given; otherwise discover the current repository. Record repository, branch/commit (if locally available), scope, source revisions, and any access boundary. If prior artefacts are missing, gather the minimum evidence needed; never refuse solely because an upstream artefact is absent. If the scope or essential source is inaccessible, state the blocker and continue with bounded local evidence where possible.

## Procedure

Follow `.github/ai-qa/framework/method/discovery.md` as the controlling evidence procedure. The LLM reasons over repository evidence, but uses that method's fixed domains, sampling guidance, status definitions, citation requirements and output structure.

1. Confirm repository, branch/commit and scope. Record the read-only commands used and source locations. Inspect repository shape (including workspaces, multi-module layouts and solutions), README/docs index, manifests, wrappers, lockfiles, framework configuration, source and test roots, CI/deploy files, interfaces, local environments, and infrastructure configuration. In small repositories read everything relevant; in large ones sample across paths, modules, test levels and recency until patterns stabilise.
2. Find requirements and acceptance-criteria sources in local specifications, docs, ADRs, supplied ticket content, README/CONTRIBUTING, and repo templates. Use a remote source only after the provider and transport have been confirmed and are accessible. For remote documentation, the user must name a space or root page; use `docs.search`/`docs.get`, index-first, with minimum reading. If a configured work-item fetch fails, retry once then request pasted title, description and ACs; report the inaccessible remote fact as `?`, not `∅`.
3. Identify service boundaries and domain-critical flows; interfaces, identity/auth and permissions; feature flags; data ownership; databases, queues, caches and third parties; logging, metrics and audit; rollout and environment differences. Separate directly observed facts from hypotheses.
4. Inspect test stack, paths, naming, fixtures/builders, setup/teardown, tags, assertions, base classes, test data, mocking, environment/base URL configuration, commands, reports, and test level. Sample proportionally across distinct paths and levels. State sample size and matched proportion, and give 2–3 real examples when available (otherwise all available examples). Different test practices may be `✗` No consistent convention; incompatible sources are `⚠` Conflict. Test existence is not evidence of a passing result.
5. Cover every domain in `.github/ai-qa/framework/method/discovery.md`, including Git branches/commits, PR templates and recent merged PRs when an available transport allows them; CODEOWNERS; DoD and QA evidence; manual scenario format (how acceptance criteria and any existing manual test cases are written: Given/When/Then, step lists or free text); docs roots, ADRs and wiki links; provider URLs, work-item syntax, configured `.vscode/mcp.json`, authenticated CLI status and environment-variable names. Never expose credential values or personal data.
6. Allowed read-only probes are limited to repository reads and harmless status/help/list operations, such as `git log`/branch inspection, `gh auth status`, `az account show`, and a relevant command's `--help` or list option. Do not run a test suite, install command, migration, deployment, provisioning operation, or command with a write side effect. If a command's safety is unclear, do not run it; record `?` and the reason.
7. Use the seven statuses distinctly: `✓` Observed (direct evidence); `◐` Inferred (state basis and sample); `⚠` Conflict (show both sides); `∅` Not found (bounded search recorded); `?` Could not check (state blocker); `✗` No consistent convention (show divergent examples); `★` Default established (dated, user-approved, Configure only; never create it here). Do not merge statuses, confuse `∅` with `?`, infer from one example, or present inference as observation.

## Output

Produce a concise dated discovery report grouped by the domains and format in `framework/method/discovery.md`. Every finding includes status, conclusion, evidence (repository-relative paths with real line numbers and/or read-only command), and a note. Include scope, revision, commands, sample size/fraction, actual examples, source freshness, exclusions and limitations. End with **Needs your input** for genuine blockers, behaviour-relevant conflicts or essential scope; ask one focused question per decision and explain what it unlocks. Do not repeatedly ask about nonblocking gaps.

When invoked by `qa-configure`, return the report as evidence for its preview; do not write any files. Standalone, write only `qa-work/<work-id>/discovery.md` (or return it in chat if no suitable work branch/index is available), with the front matter required by `.github/ai-qa/framework/method/artefacts.md`: `work-id`, `skill: qa-discover`, `framework-version`, `created`, and `inputs`. Update `qa-work/<work-id>/index.md` with branch, scope, source revision, unknowns/conflicts, freshness, and report link. Never write `.github/ai-qa/project/**`, including project `discovery.md`; only `qa-configure` can persist there. Offer the snapshot to other skills without making it a prerequisite.

## Side effects and safety

| Action | Level | Gate |
|---|---:|---|
| Read repository files and inspect Git/status/help/list output | L0 | None; no write or test execution |
| Read-only provider operations `workitem.get`, `workitem.search`, `docs.search`, `docs.get`, `repo.pr.list`, or `ci.*` when already configured | L0 | None; use configured provider and transport only |
| Write standalone discovery artefact and update `qa-work/<work-id>/index.md` | L1 local artefact edit | No standalone gate; an orchestrated workflow requires its plan approval first. Confirm a non-default branch before writing. |
| Modify project conventions, rendered instructions, or `.vscode/mcp.json` | L5 | Prohibited for this skill; hand off to `qa-configure` after preview/approval. |

## Drift

If evidence contradicts project conventions or `project.md`, record both sides under **Drift** in the discovery artefact and suggest `qa-configure refresh`; never edit `.github/ai-qa/project/**` yourself.
