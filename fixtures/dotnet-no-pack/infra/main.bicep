param environment string
param location string = resourceGroup().location

resource billingPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'asp-billing-${environment}'
  location: location
  sku: {
    name: 'B1'
    tier: 'Basic'
  }
}

output planId string = billingPlan.id