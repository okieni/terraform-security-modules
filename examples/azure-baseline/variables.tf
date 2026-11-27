variable "subscription_id" {
  description = "Azure subscription to deploy into."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
  default     = "canadacentral"
}

variable "alert_emails" {
  description = "Emails for security alerts."
  type        = list(string)
  default     = []
}

variable "allowed_ip_ranges" {
  description = "Your public IP(s), so Terraform and you can reach the Key Vault and storage data planes."
  type        = list(string)
  default     = []
}
