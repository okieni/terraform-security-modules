# azure/storage-account

A StorageV2 account with secure defaults.

| Control | Setting |
|---|---|
| Transport | HTTPS only, TLS 1.2 minimum |
| Public access | Anonymous blob access off; public endpoint off; firewall default **Deny** |
| Auth | Shared keys/SAS off, Entra ID (OAuth) by default |
| Encryption | Infrastructure (double) encryption; optional customer managed key |
| Data protection | Blob versioning, change feed, 30-day blob and container soft delete |
| Replication | GZRS by default, cross-tenant replication off |
| Logging | Blob `allLogs` to Log Analytics |

Maps to CIS Microsoft Azure Foundations 3.x (Storage Accounts).

## Usage

```hcl
provider "azurerm" {
  features {}
  storage_use_azuread = true # needed because shared keys are disabled
}

module "storage" {
  source              = "../../modules/azure/storage-account"
  name                = "stacmeprod01"
  location            = "canadacentral"
  resource_group_name = azurerm_resource_group.security.name
  allowed_ip_ranges   = ["203.0.113.10"]
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `name` | Account name | required |
| `location` | Region | required |
| `resource_group_name` | Resource group | required |
| `replication_type` | Replication | `GZRS` |
| `shared_access_key_enabled` | Allow keys/SAS | `false` |
| `public_network_access_enabled` | Public endpoint | `false` |
| `allowed_ip_ranges` | Firewall IPs | `[]` |
| `allowed_subnet_ids` | Firewall subnets | `[]` |
| `soft_delete_retention_days` | Soft-delete days | `30` |
| `cmk_key_vault_id` | Key Vault for CMK | `null` |
| `cmk_key_vault_key_id` | CMK key ID | `null` |
| `log_analytics_workspace_id` | Log destination | `null` |
| `tags` | Tags | `{}` |

## Outputs

`id`, `name`, `principal_id`
