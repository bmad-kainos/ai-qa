# Billing

.NET 8 solution with API and xUnit tests. Use `dotnet test Billing.sln --logger trx`; filter a class with `--filter FullyQualifiedName~InvoiceTests`. The service deploys via Azure Pipelines and uses `BILLING_API_URL` in non-local test environments.
