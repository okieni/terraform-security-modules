terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

data "azurerm_subscription" "current" {}

# Central workspace for security logs (also used by the other Azure modules).
resource "azurerm_log_analytics_workspace" "this" {
  count               = var.existing_workspace_id == null ? 1 : 0
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

locals {
  workspace_id = var.existing_workspace_id != null ? var.existing_workspace_id : azurerm_log_analytics_workspace.this[0].id
}

# Export the subscription Activity Log (CIS Azure 5.1.x).
resource "azurerm_monitor_diagnostic_setting" "activity_log" {
  name                       = "activity-log-to-law"
  target_resource_id         = data.azurerm_subscription.current.id
  log_analytics_workspace_id = local.workspace_id

  dynamic "enabled_log" {
    for_each = toset([
      "Administrative", "Security", "ServiceHealth", "Alert",
      "Recommendation", "Policy", "Autoscale", "ResourceHealth",
    ])
    content {
      category = enabled_log.value
    }
  }
}

# ---- Activity log alerts for security-sensitive changes (CIS Azure 5.2.x) ----

resource "azurerm_monitor_action_group" "this" {
  count               = length(var.alert_emails) > 0 ? 1 : 0
  name                = "security-alerts"
  resource_group_name = var.resource_group_name
  short_name          = "secalerts"

  dynamic "email_receiver" {
    for_each = var.alert_emails
    content {
      name                    = "email-${email_receiver.key}"
      email_address           = email_receiver.value
      use_common_alert_schema = true
    }
  }

  tags = var.tags
}

resource "azurerm_monitor_activity_log_alert" "this" {
  for_each = length(var.alert_emails) > 0 ? var.alert_operations : {}

  name                = "alert-${each.key}"
  resource_group_name = var.resource_group_name
  location            = "global"
  scopes              = [data.azurerm_subscription.current.id]
  description         = "Fires on ${each.value}"

  criteria {
    category       = "Administrative"
    operation_name = each.value
  }

  action {
    action_group_id = azurerm_monitor_action_group.this[0].id
  }

  tags = var.tags
}
