# Discovery — java-ado

| Domain | Status | Conclusion | Evidence | Note |
|---|---|---|---|---|
| Repo shape/build | ✓ Observed | Single Gradle Java project | `build.gradle.kts:1-8`, `settings.gradle.kts:1` | No Gradle wrapper present. |
| Test stack | ◐ Inferred | JUnit 5 and RestAssured dependencies | `build.gradle.kts:4-7` | No test sources to sample; do not claim execution. |
| Execution | ⚠ Conflict | README mentions integration tests but build defines only the `test` task | `README.md:3`, `build.gradle.kts:8`, `azure-pipelines.yml:7-12` | Confirm integration test command. |
| CI/CD | ✓ Observed | Azure Pipelines runs Gradle unit tests and publishes JUnit XML | `azure-pipelines.yml:1-12` | No deployment stage. |
| Project context | ✓ Observed | Orders API, Postgres and Terraform environment input | `docs/openapi.yaml:1-16`, `compose.yaml:1-8`, `infra/main.tf:1-11` | No production URL or credentials. |
| Work items | ◐ Inferred | Azure Boards key `ORD-123` | `README.md:3` | Confirm provider/organisation via read-only probe. |
| PR conventions | ∅ Not found | No PR template or exemplar | Repository scan | Ask only if PR creation requested. |

Sample: manifest, pipeline, README, OpenAPI, Compose, Terraform and ADR (7/7 evidence categories examined); no test files exist to compare conventions. Examples: `build.gradle.kts:5`, `azure-pipelines.yml:8`, `docs/openapi.yaml:5`.

## Needs your input

- Which configured integration-test task should be used?
- What Azure DevOps organisation/project hosts `ORD-123` work items?
