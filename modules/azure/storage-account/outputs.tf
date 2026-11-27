output "id" {
  description = "Resource ID of the storage account."
  value       = azurerm_storage_account.this.id
}

output "name" {
  description = "Name of the storage account."
  value       = azurerm_storage_account.this.name
}

output "principal_id" {
  description = "Principal ID of the account's system-assigned identity."
  value       = azurerm_storage_account.this.identity[0].principal_id
}
