using Billing.Api;
using Xunit;

namespace Billing.Tests;

public class InvoiceTests
{
    [Fact]
    public void TotalOfEmptyInvoiceIsZero()
    {
        Assert.Equal(0m, InvoiceCalculator.Total([]));
    }

    [Fact]
    public void TotalIncludesEachLineQuantity()
    {
        var lines = new[] { new InvoiceLine("A-1", 12.50m, 2), new InvoiceLine("B-2", 3m, 1) };

        Assert.Equal(28m, InvoiceCalculator.Total(lines));
    }
}
