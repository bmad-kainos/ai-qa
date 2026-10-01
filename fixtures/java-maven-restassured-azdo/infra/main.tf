terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  type = string
}

variable "location" {
  type    = string
  default = "uksouth"
}

resource "azurerm_resource_group" "orders" {
  name     = "rg-orders-${var.environment}"
  location = var.location
}

output "orders_environment" {
  value = var.environment
}
