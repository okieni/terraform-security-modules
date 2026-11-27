variable "name" {
  description = "Name of the network security group."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group for the NSG."
  type        = string
}

variable "rules" {
  description = "Custom rules. Priorities 100-4095. Management ports (22, 3389) can't be opened to the internet."
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = optional(string, "*")
  }))
  default = []

  validation {
    condition     = alltrue([for r in var.rules : r.priority >= 100 && r.priority <= 4095])
    error_message = "Rule priorities must be between 100 and 4095 (4096 is reserved for DenyAllInbound)."
  }

  # Guardrail (CIS Azure 6.1 / 6.2): no SSH or RDP from the internet.
  validation {
    condition = alltrue([
      for r in var.rules : !(
        r.direction == "Inbound" &&
        r.access == "Allow" &&
        contains(["*", "Internet", "Any", "0.0.0.0/0"], r.source_address_prefix) &&
        contains(["*", "22", "3389"], r.destination_port_range)
      )
    ])
    error_message = "Inbound SSH (22) or RDP (3389) from the internet is not allowed. Use Azure Bastion or a specific source range."
  }
}

variable "deny_all_inbound" {
  description = "Add an explicit DenyAllInbound rule at priority 4096."
  type        = bool
  default     = true
}

variable "subnet_ids" {
  description = "Subnets to associate with this NSG."
  type        = list(string)
  default     = []
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics workspace for NSG logs."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to the NSG."
  type        = map(string)
  default     = {}
}
