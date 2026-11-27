variable "finding_publishing_frequency" {
  description = "How often updated findings are published: FIFTEEN_MINUTES, ONE_HOUR or SIX_HOURS."
  type        = string
  default     = "FIFTEEN_MINUTES"

  validation {
    condition     = contains(["FIFTEEN_MINUTES", "ONE_HOUR", "SIX_HOURS"], var.finding_publishing_frequency)
    error_message = "Must be FIFTEEN_MINUTES, ONE_HOUR or SIX_HOURS."
  }
}

variable "features" {
  description = "GuardDuty protection plans to enable."
  type        = list(string)
  default = [
    "S3_DATA_EVENTS",
    "EKS_AUDIT_LOGS",
    "EBS_MALWARE_PROTECTION",
    "RDS_LOGIN_EVENTS",
    "LAMBDA_NETWORK_LOGS",
  ]
}

variable "enable_alerts" {
  description = "Send findings at or above alert_min_severity to an SNS topic."
  type        = bool
  default     = true
}

variable "alert_min_severity" {
  description = "Minimum severity to alert on (1-8.9). 7 = High."
  type        = number
  default     = 7
}

variable "alert_emails" {
  description = "Email addresses subscribed to the alert topic (each must confirm the subscription)."
  type        = list(string)
  default     = []
}

variable "sns_kms_key_id" {
  description = "Customer managed KMS key for the SNS topic; its policy must allow events.amazonaws.com (pass it via the kms-key module's service_principals). The AWS managed alias/aws/sns key will NOT work with EventBridge."
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
