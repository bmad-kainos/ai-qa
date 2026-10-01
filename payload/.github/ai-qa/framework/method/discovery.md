# Repository discovery and Project Context evidence

Discovery is read-only (L0). The LLM reasons over repository and user evidence, but follows this fixed procedure for what to examine, how to report it, and what counts as evidence. Never run the test suite. Read `safety.md`, `precedence.md`, this method, `.github/ai-qa/project/project.md` and applicable project conventions if they exist. Templates/defaults are examples, not project facts. QA produces a session Project Context; only `qa-configure` writes persistent project files after L5 approval.

## Evidence statuses — never merged

| Mark | Status | Meaning |
|---|---|---|
| ✓ | **Observed** | Directly inspected in a named file/line, configuration, command output or confirmed user statement; cite it. |
| ◐ | **Inferred** | State the basis and sample. Never present an inference as an observation. |
| ⚠ | **Conflict** | Show both sides and their evidence. |
| ∅ | **Not found** | A bounded search found nothing; report searched scope. |
| ? | **Could not check** | Explain the access, permission, missing tool or data blocker. |
| ✗ | **No consistent convention** | Representative examples show incompatible practices; cite them. |
| ★ | **Default established** | Configure only, after approval; include date, approver and rationale. |

Keep `∅` and `?` separate. Do not turn `◐` into `✓` because multiple files share an extension. For convention claims report sample size and proportion (`files examined / relevant files identified`) and 2–3 representative examples; if fewer exist, show all. Sample across directories, modules, levels and recency. In small repositories read everything; in large repositories stop once the pattern stabilises. For Git/PR conventions recency beats volume. Report mixed practices as `✗`, contradictory authoritative configuration as `⚠`.

## Project Context evidence-source order

1. **Repository:** manifests, layout, service boundaries, OpenAPI/AsyncAPI, compose, IaC (Terraform/Bicep/ARM/Helm/Kubernetes), environment configuration files (keys only, never secret values), CI deploy stages.
2. **Repository documentation:** README, `docs/`, ADRs, CONTRIBUTING and runbooks.
3. **Remote documentation:** Azure Wiki or Confluence only if configured and the user named the space or root page. This is a second pass after integrations are confirmed. Use `docs.search` / `docs.get`, index pages first and minimal reading.
4. **User:** only for genuine unknowns or conflicts.

Configure inspects the repository and proposes detected defaults before asking. Interview only for conflicts, behaviour-relevant inferences, inaccessible checks or relevant missing information. Keep Project Context (“what the project is”) distinct from conventions (“how AI-QA operates on it”). Explorer investigates only the areas needed for the ticket and returns likely files/symbols, control/data flow, dependencies, side effects, edge cases and relevant tests/commands; prefer precise findings over broad repo tours.

## Discovery domains

Record status, conclusion and evidence for every domain. “Not applicable” also needs evidence.

| Domain | Examine; evidence that supports a conclusion |
|---|---|
| Repo shape | Root layout, workspaces, multi-module structure and solution files such as `.sln`; cite directory paths and manifests. |
| Languages and build | Language manifests, versions, wrappers, lockfiles and build configuration; cite exact files/lines. |
| App frameworks and data | Framework manifests, DB declarations, migrations, compose and IaC; configuration is evidence, not a running service. |
| Test stack and pack match | Runner/configuration, test dependencies and representative tests; state detected signals and matching pack, no-pack, or framework-not-found result. |
| Test structure and conventions | Naming, locations, fixtures, builders, tags, assertions, base classes, environment/base-URL configuration and test data; give sample fraction and 2–3 real examples. |
| Execution | Scripts, CI steps, README commands and report outputs; distinguish documented/configured commands from commands actually run. |
| CI/CD | Jobs, triggers, artefacts and deployment stages from workflow/pipeline files. |
| Git | Recent branches, non-merge and merge commits, ticket patterns and source recency; never infer base branch without conventions. |
| PRs | GitHub and ADO templates, contributing docs and recent merged PRs when a transport is available; recency beats volume. |
| CODEOWNERS | `CODEOWNERS` locations and relevant path ownership, or bounded search evidence. |
| Definition of done and QA evidence | CONTRIBUTING, project docs, templates, CI checks, test reports or confirmed user statement. |
| Documentation | Documentation root, ADRs, wiki links and index/home/glossary pages. |
| Integrations | Remote host, ticket syntax, Atlassian/ADO URLs, `.vscode/mcp.json`, authenticated CLIs (`gh auth status`, `az account show`) and environment-variable names. Record only status/identity metadata; never expose tokens or secret values. |
| Project context | Purpose, components, technology stack, environments, data stores/dependencies, CI/CD, test landscape, constraints, docs, unknowns/conflicts and provenance; link sources and confidence. |

For inaccessible environments or integrations record `?`; do not try live tests. A configured URL is not proof of access. Never run install, migration, deployment, provisioning commands or the suite during discovery. Inspect scripts and data as text. Missing optional integrations do not prevent analysis from pasted content.

## Sampling and evidence

Sampling is guidance, not a fixed threshold. Sample across directories, modules, levels and recency; read everything in small repositories; in large repositories stop once the pattern stabilises. Report what was sampled, the proportion that matched and 2–3 real examples. For test conventions do not claim a project-wide rule from one test. For Git and PR conventions, recency beats volume. Never present an inference as an observation.

Evidence includes paths with line numbers, commands and relevant output, confirmed links, source/revision and observation date. Record search/inspection commands and branch/commit. Distinguish observed facts, user statements, inferences and conflicts.

## Output

Write the report to `.github/ai-qa/project/discovery.md` through `qa-configure` after the required approval. Group it by every discovery domain. Each entry records **status**, **conclusion**, **evidence** (paths with line numbers and/or commands) and **note**. Include sampling proportions/examples, revision/date, exclusions and freshness limits. End with a **Needs your input** section containing only unresolved conflicts, access blockers or genuinely behaviour-relevant unknowns; show evidence and the decision each answer unlocks. Do not write project files from a QA skill.

If configured ticket retrieval fails, retry once; then ask for pasted title, description and acceptance criteria, and continue. Never ask for information already answered by repository evidence. Route persistent setup/refresh to `qa-configure` and focused work to its matching skill.
