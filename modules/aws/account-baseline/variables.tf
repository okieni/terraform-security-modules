variable "minimum_password_length" {
  description = "Minimum IAM user password length (CIS recommends 14+)."
  type        = number
  default     = 14

  validation {
    condition     = var.minimum_password_length >= 14
    error_message = "Use at least 14 characters."
  }
}

variable "max_password_age" {
  description = "Days before IAM user passwords expire. 0 = never (NIST 800-63B guidance)."
  type        = number
  default     = 0
}

variable "ebs_kms_key_arn" {
  description = "Customer managed KMS key for default EBS encryption. Null = AWS managed key."
  type        = string
  default     = null
}

variable "enable_access_analyzer" {
  description = "Create an IAM Access Analyzer."
  type        = bool
  default     = true
}

variable "access_analyzer_name" {
  description = "Name of the Access Analyzer."
  type        = string
  default     = "account-access-analyzer"
}

variable "access_analyzer_type" {
  description = "ACCOUNT or ORGANIZATION."
  type        = string
  default     = "ACCOUNT"

  validation {
    condition     = contains(["ACCOUNT", "ORGANIZATION"], var.access_analyzer_type)
    error_message = "Must be ACCOUNT or ORGANIZATION."
  }
}

variable "enable_security_hub" {
  description = "Enable Security Hub with the Foundational Best Practices and CIS v3.0 standards."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied where supported."
  type        = map(string)
  default     = {}
}
