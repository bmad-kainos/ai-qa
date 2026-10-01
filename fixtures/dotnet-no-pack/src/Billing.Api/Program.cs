using Billing.Api;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

app.MapPost("/invoices/total", (IEnumerable<InvoiceLine> lines) =>
    Results.Ok(new { total = InvoiceCalculator.Total(lines) }));

app.Run();