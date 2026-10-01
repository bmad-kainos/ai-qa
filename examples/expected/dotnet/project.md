# Project Context — Billing

<!-- ai-qa:managed -->
## Summary
Medium: Billing test solution ([README](../../fixtures/dotnet/README.md)).
## Components
| Component | Type | Path | Tech | Purpose |
|---|---|---|---|---|
| Billing.Tests | test suite | `tests/Billing.Tests/` | .NET/xUnit | Invoice validation |
## Technology stack
High: .NET 8 and xUnit ([project](../../fixtures/dotnet/tests/Billing.Tests/Billing.Tests.csproj)).
## Environments
Medium: `BILLING_API_URL` configures a non-local target; URL unknown ([README](../../fixtures/dotnet/README.md)).
## Data stores and external dependencies
Low: none documented ([discovery](discovery.md)).
## CI/CD
High: Azure Pipelines invokes `dotnet test` ([pipeline](../../fixtures/dotnet/azure-pipelines.yml)).
## Test landscape
High: xUnit test class and TRX logging ([test](../../fixtures/dotnet/tests/Billing.Tests/InvoiceTests.cs), [README](../../fixtures/dotnet/README.md)).
## Constraints
Low: no documented constraints ([README](../../fixtures/dotnet/README.md)).
## Documentation sources
High: [README](../../fixtures/dotnet/README.md).
## Unknowns and conflicts
High: application source and test-safe environment absent from fixture ([discovery](discovery.md)).
## Provenance
High: local fixture files; no remote probe or run.
<!-- ai-qa:user -->
Preserved project notes.
