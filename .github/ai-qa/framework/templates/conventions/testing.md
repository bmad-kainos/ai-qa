# Testing conventions

Configure renders this source into `.github/ai-qa/project/conventions/testing.md` after discovery and L5 approval. Record evidence and sampling for each scope. Environment-variable names only; never secret values.

## Scopes

| Test path | Level | Pack | Location | Naming | Fixtures/builders | Tags | Base classes | Assertions | Status | Evidence/source |
|---|---|---|---|---|---|---|---|---|---|---|
| <test path/scope> | <unit/integration/E2E/manual> | <observed pack or none> | <location> | <pattern> | <paths/patterns> | <tags> | <base classes> | <style> | <status> | <paths/lines, sample, revision> |

## Commands

| Command kind | Command / selector | Status | Evidence/source |
|---|---|---|---|
| All | <configured command> | <status> | <manifest/CI/docs path and lines> |
| Path | <configured path command> | <status> | <source> |
| Tag | <configured tag command> | <status> | <source> |
| Lint/compile | <configured command> | <status> | <source> |
| List/help | <safe list/help command> | <status> | <source> |

## Reports

| Format | Path | Coverage source | Status | Evidence/source |
|---|---|---|---|---|
| <format> | <path> | <structured report/none> | <status> | <source> |

## Environments and base URLs

| Environment | Purpose / allowed use | Base URL variable name | Other variable names | Status | Evidence/source |
|---|---|---|---|---|---|
| <environment> | <purpose and restrictions> | <NAME only> | <NAMES only> | <status> | <source> |

## Test data rules

| Rule | Value | Status | Evidence/source |
|---|---|---|---|
| Ownership, source and permitted data | <rule> | <status> | <source> |
| Fixture naming, isolation and cleanup | <rule> | <status> | <source> |
| Retention/privacy constraints | <rule> | <status> | <source> |

## Manual testing ownership

| Behaviour / level | Owner | Evidence/status | Source |
|---|---|---|---|
| <manual verification responsibility> | <role/team> | <status> | <source> |

Unit tests are developer-owned unless project evidence says otherwise. QA assesses whether they exist and cover requirements; distinguish test existence, assertion relevance, run result and measured coverage. Apply `method/dedup-rule.md` to avoid duplicate manual scenarios.