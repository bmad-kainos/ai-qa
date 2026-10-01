# Discovery — Billing Service

Scope: complete fixture snapshot. Sampled solution, API project, xUnit project/tests, README, pipeline, Bicep and ADR. Test sample: 2/2 `[Fact]` methods in 1/1 test files; no suite was run. This .NET/xUnit stack has no matching installed v1 pack, so pack-specific guidance has reduced confidence.

| Domain | Status | Finding | Evidence | Note |
|---|---|---|---|---|
| Identity and ownership | ✓ Observed | Billing Service calculates invoice totals. | `README.md:3` | Team owner not identified. |
| Architecture and interface | ✓ Observed | API exposes invoice total endpoint and calculator. | `src/Billing.Api/Program.cs:6`, `src/Billing.Api/InvoiceCalculator.cs:5` | No auth scheme documented. |
| Stack and build | ✓ Observed | .NET 8 solution with API and xUnit test project. | `Billing.sln:4`, `tests/Billing.Tests/Billing.Tests.csproj:3`, `tests/Billing.Tests/Billing.Tests.csproj:10` | No matching pack; reduced confidence. |
| Source and docs layout | ✓ Observed | API source under `src/`, tests under `tests/`, Bicep under `infra/`. | `README.md:3`, `infra/main.bicep:1` | — |
| Test inventory and conventions | ✓ Observed | Two xUnit facts cover empty invoice and line quantity totals. | `tests/Billing.Tests/InvoiceTests.cs:8`, `tests/Billing.Tests/InvoiceTests.cs:14` | Sample 2/2 facts in one class. |
| Execution and reporting | ✓ Observed | `dotnet test Billing.sln --logger trx`; pipeline publishes TRX. | `README.md:7`, `azure-pipelines.yml:16`, `azure-pipelines.yml:20` | No command run. |
| Environments and deployment | ✓ Observed | `BILLING_API_URL` names non-local endpoint; pipeline has staging deployment; Bicep provisions App Service plan. | `README.md:11`, `azure-pipelines.yml:23`, `infra/main.bicep:4` | Endpoint value not present. |
| Git and review | ∅ Not found | Branch, commit, PR and reviewer conventions absent from local fixture. | Bounded fixture scan | Ask only if creating a branch or PR. |
| Work items | ◐ Inferred | Self-hosted Jira URL suggests Server/DC deployment. | `README.md:13` | `serverInfo` deployment type and authentication remain unverified. |
| CI/CD | ✓ Observed | Azure Pipelines tests before main-branch deploy hand-off. | `azure-pipelines.yml:2`, `azure-pipelines.yml:23` | Release implementation is external. |
| Requirements and docs | ∅ Not found | No local ticket/acceptance criteria source or remote docs root identified. | `README.md:13`, bounded fixture scan | Jira is only linked by example issue. |
| QA/reporting | ∅ Not found | No telemetry or QA audience rules; only TRX test results are present. | `azure-pipelines.yml:20` | — |
| Remote access | ? Could not check | Self-hosted Jira `serverInfo`, provider access, and current remote issues were not probed. | Read-only fixture inspection | Confirm before choosing Server/DC transport. |

## Needs your input

- Confirm that `jira.billing.example.org` is the active Jira Server/DC deployment, and identify its base URL and available read-only transport. The hostname is only an inference until confirmed.
