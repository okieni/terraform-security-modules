variable "plans" {
  description = "Defender for Cloud plans to enable at the Standard tier."
  type        = list(string)
  default = [
    "VirtualMachines",
    "StorageAccounts",
    "KeyVaults",
    "Arm",
    "SqlServers",
    "AppServices",
    "Containers",
    "CloudPosture",
  ]
}

variable "security_contact_email" {
  description = "Email for security alert notifications."
  type        = string
  default     = null
}

variable "security_contact_phone" {
  description = "Phone number for the security contact (optional)."
  type        = string
  default     = null
}

variable "assign_mcsb" {
  description = "Assign the Microsoft Cloud Security Benchmark policy initiative to the subscription. Note: Defender for Cloud often assigns it automatically; set false if it already exists."
  type        = bool
  default     = false
}
