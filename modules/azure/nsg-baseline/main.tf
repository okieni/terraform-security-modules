terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

resource "azurerm_network_security_group" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Caller-defined allow/deny rules (validated in variables.tf).
resource "azurerm_network_security_rule" "custom" {
  for_each = { for r in var.rules : r.name => r }

  name                        = each.value.name
  priority                    = each.value.priority
  direction                   = each.value.direction
  access                      = each.value.access
  protocol                    = each.value.protocol
  source_port_range           = "*"
  destination_port_range      = each.value.destination_port_range
  source_address_prefix       = each.value.source_address_prefix
  destination_address_prefix  = each.value.destination_address_prefix
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

# Explicit deny-all at the lowest custom priority, so nothing slips through
# Azure's built-in "AllowVnetInBound" / "AllowAzureLoadBalancerInBound" rules
# unless you allow it on purpose.
resource "azurerm_network_security_rule" "deny_all_inbound" {
  count                       = var.deny_all_inbound ? 1 : 0
  name                        = "DenyAllInbound"
  priority                    = 4096
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = var.resource_group_name
  network_security_group_name = azurerm_network_security_group.this.name
}

resource "azurerm_subnet_network_security_group_association" "this" {
  for_each                  = toset(var.subnet_ids)
  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.this.id
}

# NSG event and rule-counter logs.
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = "nsg-logs-to-law"
  target_resource_id         = azurerm_network_security_group.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}
