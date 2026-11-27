variable "region" {
  description = "AWS Region to deploy into."
  type        = string
  default     = "ca-central-1"
}

variable "alert_emails" {
  description = "Emails that receive GuardDuty high-severity alerts."
  type        = list(string)
  default     = []
}

variable "vpc_id" {
  description = "Existing VPC to enable flow logs on. Null = skip."
  type        = string
  default     = null
}
