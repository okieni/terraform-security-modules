terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

# Enable Defender plans (Standard tier) for each resource type.
resource "azurerm_security_center_subscription_pricing" "this" {
  for_each      = toset(var.plans)
  tier          = "Standard"
  resource_type = each.value
}

# Who gets emailed about high-severity alerts (CIS Azure 2.1.19-2.1.21).
resource "azurerm_security_center_contact" "this" {
  count = var.security_contact_email == null ? 0 : 1
  name  = "default"
  email = var.security_contact_email
  phone = var.security_contact_phone

  alert_notifications = true
  alerts_to_admins    = true
}

# Assign the Microsoft Cloud Security Benchmark initiative so compliance
# shows up in the Defender for Cloud regulatory compliance dashboard.
data "azurerm_subscription" "current" {}

resource "azurerm_subscription_policy_assignment" "mcsb" {
  count                = var.assign_mcsb ? 1 : 0
  name                 = "mcsb"
  display_name         = "Microsoft Cloud Security Benchmark"
  subscription_id      = data.azurerm_subscription.current.id
  policy_definition_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"
}
