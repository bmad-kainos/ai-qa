terraform {
  required_version = ">= 1.5.0"
}

variable "environment" {
  type = string
}

output "orders_environment" {
  value = var.environment
}
