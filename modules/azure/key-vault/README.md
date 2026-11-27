# azure/key-vault

An Azure Key Vault with secure defaults.

| Control | Setting |
|---|---|
| Authorization | Azure RBAC (no legacy access policies) |
| Deletion | Purge protection on, 90-day soft delete |
| Network | Firewall default **Deny**; public access off by default; optional private endpoint |
| Keys | Premium SKU (HSM-backed) by default |
| Logging | `allLogs` (includes audit) to Log Analytics |

Maps to CIS Microsoft Azure Foundations 8.x (Key Vault).

## Usage

```hcl
module "kv" {
  source                     = "../../modules/azure/key-vault"
  name                       = "kv-acme-prod-01"
  location                   = "canadacentral"
  resource_group_name        = azurerm_resource_group.security.name
  log_analytics_workspace_id = module.activity_log.workspace_id
  role_assignments = [
    { role = "Key Vault Secrets User", principal_id = azurerm_user_assigned_identity.app.principal_id },
  ]
}
```

> With public access disabled, Terraform itself needs network line-of-sight (private endpoint, allowed IP, or a self-hosted runner) to create secrets or keys inside the vault.

## Inputs

| Name | Description | Default |
|---|---|---|
| `name` | Vault name | required |
| `location` | Region | required |
| `resource_group_name` | Resource group | required |
| `sku_name` | `standard` / `premium` | `premium` |
| `soft_delete_retention_days` | 7–90 | `90` |
| `public_network_access_enabled` | Public endpoint | `false` |
| `allowed_ip_ranges` | Firewall IPs | `[]` |
| `allowed_subnet_ids` | Firewall subnets | `[]` |
| `role_assignments` | RBAC grants | `[]` |
| `log_analytics_workspace_id` | Audit log destination | `null` |
| `private_endpoint_subnet_id` | Private endpoint subnet | `null` |
| `private_dns_zone_id` | Private DNS zone | `null` |
| `tags` | Tags | `{}` |

## Outputs

`id`, `vault_uri`
