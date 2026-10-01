# Project Discovery

This report is written to `.github/ai-qa/project/discovery.md` by `qa-configure` only, after approval. Group findings by every domain below. Do not run the test suite. Use statuses exactly as defined in `method/discovery.md`: ✓ Observed · ◐ Inferred · ⚠ Conflict · ∅ Not found · ? Could not check · ✗ No consistent convention · ★ Default established (Configure only).

**Repository / scope:** <repository and requested scope>
**Branch / revision:** <confirmed branch and commit>
**Observed at:** <date/time>
**Sampling approach:** <what was sampled, proportion, 2–3 examples; small repo = read all, large repo = stop when pattern stabilises>

<!-- ai-qa:managed:repo-shape -->
## Repo shape

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <workspaces, modules, solutions, repository layout> | <evidence> | <sample/freshness/conflict/unknown> |
<!-- /ai-qa:managed:repo-shape -->

<!-- ai-qa:managed:languages-and-build -->
## Languages and build

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <languages, versions, manifests, wrappers, lockfiles, build tools> | <evidence> | <sample/freshness/conflict/unknown> |
<!-- /ai-qa:managed:languages-and-build -->

<!-- ai-qa:managed:app-frameworks-and-data -->
## App frameworks and data

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <frameworks, databases, migrations, compose, IaC> | <evidence> | <configuration only; do not infer a running service> |
<!-- /ai-qa:managed:app-frameworks-and-data -->

<!-- ai-qa:managed:test-stack-and-pack-match -->
## Test stack and pack match

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <runner, test dependencies, representative tests, matched pack or no-pack> | <evidence> | <sample/freshness/conflict/unknown> |
<!-- /ai-qa:managed:test-stack-and-pack-match -->

<!-- ai-qa:managed:test-structure-and-conventions -->
## Test structure and conventions

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <names, locations, fixtures/builders, tags, assertions, bases, env/base URL, data> | <evidence> | <sample size/proportion and 2–3 examples> |
<!-- /ai-qa:managed:test-structure-and-conventions -->

<!-- ai-qa:managed:execution -->
## Execution

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <scripts, CI steps, README commands, reports; do not run suite> | <evidence> | <documented vs actually executed> |
<!-- /ai-qa:managed:execution -->

<!-- ai-qa:managed:ci-cd -->
## CI/CD

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <jobs, triggers, artefacts, deployment stages> | <evidence> | <freshness/unknown> |
<!-- /ai-qa:managed:ci-cd -->

<!-- ai-qa:managed:git -->
## Git

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <recent branches, merge/non-merge commits, ticket patterns> | <evidence> | <sample/recency; base branch comes from conventions> |
<!-- /ai-qa:managed:git -->

<!-- ai-qa:managed:prs -->
## PRs

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <GitHub/ADO templates, contributing docs, recent merged PRs if accessible> | <evidence> | <recency; transport/access limits> |
<!-- /ai-qa:managed:prs -->

<!-- ai-qa:managed:codeowners -->
## CODEOWNERS

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <relevant ownership rules or bounded search result> | <evidence> | <scope searched> |
<!-- /ai-qa:managed:codeowners -->

<!-- ai-qa:managed:definition-of-done-and-qa-evidence -->
## Definition of done and QA evidence

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <DoD, test evidence, reports, CI checks> | <evidence> | <observed vs inferred> |
<!-- /ai-qa:managed:definition-of-done-and-qa-evidence -->

<!-- ai-qa:managed:documentation -->
## Documentation

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <docs root, ADRs, wiki links, index/home/glossary> | <evidence> | <remote pass only when configured and named> |
<!-- /ai-qa:managed:documentation -->

<!-- ai-qa:managed:integrations -->
## Integrations

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <host, ticket syntax, provider URLs, MCP config, CLI auth status, env var names> | <evidence> | <never include token or secret values> |
<!-- /ai-qa:managed:integrations -->

<!-- ai-qa:managed:project-context -->
## Project context

| Status | Conclusion | Evidence (paths with lines / commands) | Note |
|---|---|---|---|
| <status> | <purpose, components, stack, environments, dependencies, CI, tests, constraints, docs, unknowns, provenance> | <evidence> | <confidence and freshness> |
<!-- /ai-qa:managed:project-context -->

## Needs your input

List only unresolved conflicts, access blockers and genuinely behaviour-relevant unknowns. Ask one focused question at a time in Option-A form, show evidence, recommend Option A and state what the answer unlocks. Never ask for secrets or information already available in the repository.

| Question | Evidence / conflict sides | Option A (recommended) | Alternative | Decision unlocked |
|---|---|---|---|---|
| <question or “None”> | <evidence> | <option> | <alternative> | <effect> |