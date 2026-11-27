variable "name" {
  description = "Globally unique storage account name (3-24 lowercase letters and numbers)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.name))
    error_message = "Use 3-24 lowercase letters and numbers."
  }
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the account."
  type        = string
}

variable "replication_type" {
  description = "LRS, ZRS, GRS, RAGRS, GZRS or RAGZRS."
  type        = string
  default     = "GZRS"
}

variable "shared_access_key_enabled" {
  description = "Allow account-key and SAS auth. Keep false and use Entra ID; set the provider's storage_use_azuread = true."
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "Allow the public endpoint (still filtered by network rules)."
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "Public IPs/CIDRs allowed through the firewall."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "Subnets (with the Microsoft.Storage service endpoint) allowed through the firewall."
  type        = list(string)
  default     = []
}

variable "soft_delete_retention_days" {
  description = "Days deleted blobs and containers are recoverable."
  type        = number
  default     = 30
}

variable "cmk_key_vault_id" {
  description = "Key Vault ID holding the customer managed key (needed with cmk_key_vault_key_id)."
  type        = string
  default     = null
}

variable "cmk_key_vault_key_id" {
  description = "Versionless Key Vault key ID for customer managed encryption. Null = Microsoft managed keys."
  type        = string
  default     = null
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace for blob logs."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
