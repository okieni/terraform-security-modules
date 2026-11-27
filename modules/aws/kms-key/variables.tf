variable "alias" {
  description = "Alias for the key, without the 'alias/' prefix."
  type        = string
}

variable "description" {
  description = "Description of the key."
  type        = string
  default     = "Customer managed key (managed by Terraform)"
}

variable "key_admin_arns" {
  description = "IAM principals allowed to administer (not use) the key. Defaults to the account root."
  type        = list(string)
  default     = []
}

variable "key_user_arns" {
  description = "IAM principals allowed to encrypt and decrypt with the key."
  type        = list(string)
  default     = []
}

variable "service_principals" {
  description = "AWS service principals allowed to use the key, e.g. [\"cloudtrail.amazonaws.com\"]."
  type        = list(string)
  default     = []
}

variable "rotation_period_in_days" {
  description = "Automatic rotation period (90-2560 days)."
  type        = number
  default     = 365

  validation {
    condition     = var.rotation_period_in_days >= 90 && var.rotation_period_in_days <= 2560
    error_message = "rotation_period_in_days must be between 90 and 2560."
  }
}

variable "deletion_window_in_days" {
  description = "Waiting period before the key is deleted (7-30 days)."
  type        = number
  default     = 30

  validation {
    condition     = var.deletion_window_in_days >= 7 && var.deletion_window_in_days <= 30
    error_message = "deletion_window_in_days must be between 7 and 30."
  }
}

variable "multi_region" {
  description = "Create a multi-Region primary key."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the key."
  type        = map(string)
  default     = {}
}
