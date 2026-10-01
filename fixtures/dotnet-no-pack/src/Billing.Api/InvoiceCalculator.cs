namespace Billing.Api;

public sealed record InvoiceLine(string Sku, decimal UnitPrice, int Quantity);

public static class InvoiceCalculator
{
    public static decimal Total(IEnumerable<InvoiceLine> lines) =>
        lines.Sum(line => line.UnitPrice * line.Quantity);
}