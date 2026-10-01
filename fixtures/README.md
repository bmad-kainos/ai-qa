# Discovery fixtures

Each directory is a small repository-shaped validation target for AI-QA v1 discovery and Configure. Run discovery against one fixture directory at a time; compare its sourced findings with the corresponding directory under `_expected/`. Expected reports are reference outcomes, not framework inputs, and fixture `.github/` directories contain only workflow, pull request template, or CODEOWNERS evidence.

| Fixture | Evidence target |
|---|---|
| `java-maven-restassured-azdo/` | Java/Maven, JUnit 5 + RestAssured, Azure Pipelines/Boards, PostgreSQL, Terraform |
| `ts-playwright-github/` | TypeScript, Playwright API + browser paths, GitHub Issues/Actions, PostgreSQL |
| `python-pytest-jira/` | pytest + httpx, unit/integration paths, Jira/Confluence Cloud, Kubernetes |
| `dotnet-no-pack/` | .NET 8 + xUnit, Azure Pipelines, self-hosted Jira Server/DC inference, no matching pack |
| `empty-repo/` | README only; no tests or CI, so Configure proposes dated `★` defaults after approval |
| `conflicting-signals/` | Jest vs Vitest/Playwright, Jira vs Azure Boards, GitHub issue template, divergent test paths |
| `monorepo-workspaces/` | npm workspaces with Playwright API and Vitest web scopes; v1 must ask which single scope to configure |

`_expected/<fixture>/discovery.md` and `project.md` show representative outputs with fixture-relative `path:line` sources. The empty-repository expected directory also includes `conventions/` to demonstrate dated Configure defaults. Validate that every citation resolves in its fixture, conflicts remain visible, unknowns are not converted to facts, and no fixture contains `.github/ai-qa/` or `.github/agents/`.