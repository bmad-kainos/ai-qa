# Discovery — dotnet

| Domain | Status | Conclusion | Evidence | Note |
|---|---|---|---|---|
| Repo shape | ✓ Observed | .NET solution and test project | `Billing.sln:1-8`, `tests/Billing.Tests/Billing.Tests.csproj:1-9` | Test project only in fixture. |
| Test stack | ✓ Observed | xUnit and Microsoft.NET.Test.Sdk | `tests/Billing.Tests/Billing.Tests.csproj:4-8`, `tests/Billing.Tests/InvoiceTests.cs:1-6` | One test sampled, 1/1 has `[Fact]`. |
| Execution | ✓ Observed | `dotnet test Billing.sln --logger trx` | `README.md:3`, `azure-pipelines.yml:1-5` | No suite run. |
| Environments | ◐ Inferred | `BILLING_API_URL` selects non-local endpoint | `README.md:3` | No environment URL observed. |
| Application source | ∅ Not found | Fixture contains no API project | `Billing.sln:1-8` | Don't invent components. |

Sample: solution, test project, one test and pipeline; one of one tests follows `[Fact]` pattern. Examples: `Billing.sln:4`, `InvoiceTests.cs:4`, `azure-pipelines.yml:4`.

## Needs your input

- Where is the billing API implementation and which environments are safe for tests?
