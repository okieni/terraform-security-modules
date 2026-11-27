terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
  }
}

resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = var.replication_type

  # Transport and access hardening.
  https_traffic_only_enabled       = true
  min_tls_version                  = "TLS1_2"
  allow_nested_items_to_be_public  = false
  shared_access_key_enabled        = var.shared_access_key_enabled
  default_to_oauth_authentication  = true
  public_network_access_enabled    = var.public_network_access_enabled
  cross_tenant_replication_enabled = false

  # Double encryption at rest.
  infrastructure_encryption_enabled = true

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices", "Logging", "Metrics"]
    ip_rules                   = var.allowed_ip_ranges
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  blob_properties {
    versioning_enabled  = true
    change_feed_enabled = true

    delete_retention_policy {
      days = var.soft_delete_retention_days
    }

    container_delete_retention_policy {
      days = var.soft_delete_retention_days
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags
}

# Customer managed key from Key Vault (optional).
resource "azurerm_role_assignment" "cmk" {
  count                = var.cmk_key_vault_key_id == null ? 0 : 1
  scope                = var.cmk_key_vault_id
  role_definition_name = "Key Vault Crypto Service Encryption User"
  principal_id         = azurerm_storage_account.this.identity[0].principal_id
}

resource "azurerm_storage_account_customer_managed_key" "this" {
  count              = var.cmk_key_vault_key_id == null ? 0 : 1
  storage_account_id = azurerm_storage_account.this.id
  key_vault_key_id   = var.cmk_key_vault_key_id
  depends_on         = [azurerm_role_assignment.cmk]
}

# Blob read/write/delete logs to Log Analytics.
resource "azurerm_monitor_diagnostic_setting" "blob" {
  count                      = var.log_analytics_workspace_id == null ? 0 : 1
  name                       = "blob-logs-to-law"
  target_resource_id         = "${azurerm_storage_account.this.id}/blobServices/default"
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category_group = "allLogs"
  }
}
