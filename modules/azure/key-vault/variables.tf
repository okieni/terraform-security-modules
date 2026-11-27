variable "name" {
  description = "Globally unique Key Vault name (3-24 chars)."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the vault."
  type        = string
}

variable "sku_name" {
  description = "standard or premium (premium = HSM-backed keys)."
  type        = string
  default     = "premium"
}

variable "soft_delete_retention_days" {
  description = "Days deleted items are recoverable (7-90)."
  type        = number
  default     = 90
}

variable "public_network_access_enabled" {
  description = "Allow access over the public endpoint (still filtered by network ACLs). Set false when using a private endpoint."
  type        = bool
  default     = false
}

variable "allowed_ip_ranges" {
  description = "Public IPs/CIDRs allowed through the firewall."
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "Subnets (with the Microsoft.KeyVault service endpoint) allowed through the firewall."
  type        = list(string)
  default     = []
}

variable "role_assignments" {
  description = "Data-plane RBAC grants, e.g. [{ role = \"Key Vault Secrets User\", principal_id = \"...\" }]."
  type = list(object({
    role         = string
    principal_id = string
  }))
  default = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace for audit logs. Strongly recommended."
  type        = string
  default     = null
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for a private endpoint. Null = no private endpoint."
  type        = string
  default     = null
}

variable "private_dns_zone_id" {
  description = "ID of the privatelink.vaultcore.azure.net DNS zone."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
