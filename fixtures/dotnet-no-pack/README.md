# Billing Service

Billing Service exposes invoice totals for the commerce platform. The .NET 8 solution contains the API and its xUnit tests. The service boundary and invoice calculation are under `src/Billing.Api/`.

## Build and test

Run `dotnet test Billing.sln --logger trx`; filter the invoice tests with `--filter FullyQualifiedName~InvoiceTests`. Results are written as TRX. The test project uses xUnit; no installed AI-QA pack currently matches this .NET test stack, so automated guidance has reduced confidence.

## Environments and delivery

Use `BILLING_API_URL` for a non-local API environment. Do not use production data in test runs. Azure Pipelines is defined in `azure-pipelines.yml`; Azure Bicep infrastructure is under `infra/`.

Billing work items are linked from the self-hosted Jira installation, for example [BILL-42](https://jira.billing.example.org/browse/BILL-42). Confirm Jira deployment and access before selecting a provider transport.
