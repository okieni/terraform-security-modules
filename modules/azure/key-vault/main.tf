terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = var.sku_name

  # Azure RBAC instead of legacy access policies.
  enable_rbac_authorization = true

  # Protect against accidental or malicious deletion.
  purge_protection_enabled   = true
  soft_delete_retention_days = var.soft_delete_retention_days

  public_network_access_enabled = var.public_network_access_enabled

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

# Grant data-plane roles, e.g. "Key Vault Secrets User" to an app identity.
resource "azurerm_role_assignment" "this" {
  for_each             = { for a in var.role_assignments : "${a.role}-${a.principal_id}" => a }
  scope                = azurerm_key_vault.this.id
  role_definition_name = each.value.role
  principal_id         = each.value.principal_id
}

# Audit logs (every secret/key access) to Log Analytics.
resource "azurerm_monitor_diagnostic_setting" "this" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = "kv-audit-to-law"
  target_resource_id         = azurerm_key_vault.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  # allLogs includes the audit category group.
  enabled_log {
    category_group = "allLogs"
  }
}

# Optional private endpoint so the vault is reachable only inside your VNet.
resource "azurerm_private_endpoint" "this" {
  count               = var.private_endpoint_subnet_id == null ? 0 : 1
  name                = "${var.name}-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = "${var.name}-psc"
    private_connection_resource_id = azurerm_key_vault.this.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }

  dynamic "private_dns_zone_group" {
    for_each = var.private_dns_zone_id == null ? [] : [1]
    content {
      name                 = "default"
      private_dns_zone_ids = [var.private_dns_zone_id]
    }
  }

  tags = var.tags
}
