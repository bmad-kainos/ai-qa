# Project Context

This is a generic source template for `.github/ai-qa/project/project.md`. Only `qa-configure` writes project-owned files, after an L5 diff preview and explicit approval. Keep Project Context (what the project is) distinct from `conventions/*.md` (how AI-QA operates on it). Link to sources rather than duplicating them. Never include credentials or secret values.

<!-- ai-qa:managed:summary -->
## Summary

<Project purpose, repository, ownership and principal user journeys.>

**Confidence:** <High / Medium / Low>
**Sources:** <repository paths/lines, links and revisions>
<!-- /ai-qa:managed:summary -->

<!-- ai-qa:user -->
<Project-authored context. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->

<!-- ai-qa:managed:components -->
## Components

| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| <component> | <service/library/application> | <repo path> | <observed technology> | <purpose> |

**Confidence:** <High / Medium / Low>
**Sources:** <paths/lines and revisions>
<!-- /ai-qa:managed:components -->

<!-- ai-qa:user -->
<Project-authored component notes. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->

<!-- ai-qa:managed:technology-stack -->
## Technology stack

<Languages and versions, runtimes, package managers, frameworks and build tools.>

**Confidence:** <High / Medium / Low>
**Sources:** <manifests/configuration paths and revisions>
<!-- /ai-qa:managed:technology-stack -->

<!-- ai-qa:user -->
<Project-authored stack notes. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->

<!-- ai-qa:managed:environments -->
## Environments

<Local, CI, test/staging/production environment roles and allowed validation targets. Test URLs and environment-variable names belong in testing conventions. Never include credentials.>

**Confidence:** <High / Medium / Low>
**Sources:** <configuration/documentation paths and revisions>
<!-- /ai-qa:managed:environments -->

<!-- ai-qa:user -->
<Project-authored environment notes. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->

<!-- ai-qa:managed:data-stores-and-external-dependencies -->
## Data stores and external dependencies

<Persistence, caches, queues, third-party services, contracts and data ownership.>

**Confidence:** <High / Medium / Low>
**Sources:** <manifests, contracts, IaC, compose and ADR paths/revisions>
<!-- /ai-qa:managed:data-stores-and-external-dependencies -->

<!-- ai-qa:user -->
<Project-authored dependency notes. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->

<!-- ai-qa:managed:ci-cd -->
## CI/CD

<Pipeline locations, jobs, test selection, reports and deployment approach.>

**Confidence:** <High / Medium / Low>
**Sources:** <workflow/pipeline paths and revisions>
<!-- /ai-qa:managed:ci-cd -->

<!-- ai-qa:user -->
<Project-authored CI/CD notes. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->

<!-- ai-qa:managed:test-landscape -->
## Test landscape

<Unit/integration/E2E/manual roots, frameworks, fixtures, naming, test packs and available coverage evidence.>

**Confidence:** <High / Medium / Low>
**Sources:** <test/configuration/CI paths, sample proportion and revisions>
<!-- /ai-qa:managed:test-landscape -->

<!-- ai-qa:user -->
<Project-authored testing notes. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->

<!-- ai-qa:managed:constraints -->
## Constraints

<Security, privacy, data retention, environments, branch rules, side effects and Do Not rules. Record names, never secret values.>

**Confidence:** <High / Medium / Low>
**Sources:** <policy/documentation/configuration paths and revisions>
<!-- /ai-qa:managed:constraints -->

<!-- ai-qa:user -->
<Project-authored constraints. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->

<!-- ai-qa:managed:documentation-sources -->
## Documentation sources

<Requirements, issue tracker, architecture, API contracts and documentation index/root. Remote sources only after integrations are confirmed and the user names the space/root.>

**Confidence:** <High / Medium / Low>
**Sources:** <links, paths and revisions>
<!-- /ai-qa:managed:documentation-sources -->

<!-- ai-qa:user -->
<Project-authored documentation notes. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->

<!-- ai-qa:managed:unknowns-and-conflicts -->
## Unknowns and conflicts

<Unresolved `?` checks and `⚠` sources, both sides, owners and next checks. Use `∅` only after a bounded search; use `✗` only when sampling shows no consistent convention.>

**Confidence:** <High / Medium / Low>
**Sources:** <conflicting paths/lines, searches and revisions>
<!-- /ai-qa:managed:unknowns-and-conflicts -->

<!-- ai-qa:user -->
<Project-authored unknowns/conflicts notes. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->

<!-- ai-qa:managed:provenance -->
## Provenance

<Discovery branch/commit, observation date, Configure approval, sources and evidence freshness.>

**Confidence:** <High / Medium / Low>
**Sources:** <discovery report, revision and approval record>
<!-- /ai-qa:managed:provenance -->

<!-- ai-qa:user -->
<Project-authored provenance notes. Configure preserves this section verbatim on refresh.>
<!-- /ai-qa:user -->