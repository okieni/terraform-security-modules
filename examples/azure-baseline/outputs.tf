output "log_analytics_workspace_id" {
  value = module.activity_log.workspace_id
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}

output "storage_account_name" {
  value = module.storage.name
}

output "nsg_id" {
  value = module.web_nsg.id
}
