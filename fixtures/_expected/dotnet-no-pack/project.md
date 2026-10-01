# Project Context — Billing Service

## Summary
High confidence: .NET 8 service calculates invoice totals. Source: `README.md:3`.

## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| Billing API | service | `src/Billing.Api/` | .NET 8 | Return invoice total |
| Invoice tests | test suite | `tests/Billing.Tests/` | xUnit | Validate total calculation |
| Billing infrastructure | infrastructure | `infra/main.bicep` | Azure Bicep | Define App Service plan |
Sources: `src/Billing.Api/Program.cs:6`, `tests/Billing.Tests/InvoiceTests.cs:8`, `infra/main.bicep:4`.

## Technology stack
High confidence: .NET 8, ASP.NET Core, xUnit. No installed v1 pack matches this stack; use existing conventions with reduced confidence. Sources: `tests/Billing.Tests/Billing.Tests.csproj:3`, `tests/Billing.Tests/Billing.Tests.csproj:10`, `README.md:7`.

## Environments
Medium confidence: non-local endpoint is supplied via `BILLING_API_URL`; staging deployment is a pipeline hand-off. Sources: `README.md:11`, `azure-pipelines.yml:23`.

## Data stores and external dependencies
Low confidence: no data store is documented in this fixture. Source: `README.md:3`.

## CI/CD
High confidence: Azure Pipelines runs xUnit and publishes TRX, then defines a main-branch staging stage. Sources: `azure-pipelines.yml:16`, `azure-pipelines.yml:20`, `azure-pipelines.yml:23`.

## Test landscape
High confidence: two xUnit facts in `InvoiceTests`; `dotnet test Billing.sln --logger trx` is documented. Sources: `tests/Billing.Tests/InvoiceTests.cs:8`, `tests/Billing.Tests/InvoiceTests.cs:14`, `README.md:7`.

## Constraints
Medium confidence: non-local target and production data must be treated cautiously; test-safe URL is not supplied. Sources: `README.md:11`, `README.md:13`.

## Documentation sources
High confidence: README and invoice-rounding ADR are local. Sources: `README.md:1`, `docs/adr/0001-invoice-rounding.md:1`.

## Unknowns and conflicts
High confidence: Jira Server/DC is inferred from a self-hosted URL and needs read-only deployment confirmation; no test-safe endpoint or Git conventions found. Sources: `README.md:13`, `discovery.md`.

## Provenance
High confidence: local fixture only; no test execution or Jira probe. Sources: `azure-pipelines.yml:16`, `README.md:13`.
