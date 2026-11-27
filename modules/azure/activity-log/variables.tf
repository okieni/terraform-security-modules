variable "location" {
  description = "Azure region for the workspace."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the workspace, action group and alerts."
  type        = string
}

variable "workspace_name" {
  description = "Name of the Log Analytics workspace to create."
  type        = string
  default     = "law-security"
}

variable "existing_workspace_id" {
  description = "Use an existing workspace instead of creating one."
  type        = string
  default     = null
}

variable "retention_in_days" {
  description = "Workspace retention (30-730 days)."
  type        = number
  default     = 365
}

variable "alert_emails" {
  description = "Emails notified by the activity log alerts. Empty = no alerts."
  type        = list(string)
  default     = []
}

variable "alert_operations" {
  description = "Map of alert-name => operation to alert on."
  type        = map(string)
  default = {
    "policy-assignment-create" = "Microsoft.Authorization/policyAssignments/write"
    "policy-assignment-delete" = "Microsoft.Authorization/policyAssignments/delete"
    "nsg-create-update"        = "Microsoft.Network/networkSecurityGroups/write"
    "nsg-delete"               = "Microsoft.Network/networkSecurityGroups/delete"
    "nsg-rule-create-update"   = "Microsoft.Network/networkSecurityGroups/securityRules/write"
    "nsg-rule-delete"          = "Microsoft.Network/networkSecurityGroups/securityRules/delete"
    "security-solution-write"  = "Microsoft.Security/securitySolutions/write"
    "security-solution-delete" = "Microsoft.Security/securitySolutions/delete"
    "sql-firewall-rule-write"  = "Microsoft.Sql/servers/firewallRules/write"
    "sql-firewall-rule-delete" = "Microsoft.Sql/servers/firewallRules/delete"
    "public-ip-create-update"  = "Microsoft.Network/publicIPAddresses/write"
    "public-ip-delete"         = "Microsoft.Network/publicIPAddresses/delete"
    "role-assignment-create"   = "Microsoft.Authorization/roleAssignments/write"
  }
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
