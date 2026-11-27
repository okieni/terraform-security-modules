variable "bucket_name" {
  description = "Globally unique name of the bucket."
  type        = string
}

variable "kms_key_arn" {
  description = "ARN of a KMS key for SSE-KMS. Leave null to use SSE-S3 (AES256)."
  type        = string
  default     = null
}

variable "access_log_bucket" {
  description = "Name of a bucket to receive S3 server access logs. Leave null to disable."
  type        = string
  default     = null
}

variable "noncurrent_version_expiration_days" {
  description = "Days to keep old object versions before deleting them."
  type        = number
  default     = 90
}

variable "additional_policy_json" {
  description = "Extra bucket policy documents (JSON) merged with the built-in TLS deny statements."
  type        = list(string)
  default     = []
}

variable "force_destroy" {
  description = "Allow Terraform to delete the bucket even when it contains objects. Keep false outside labs."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to the bucket."
  type        = map(string)
  default     = {}
}
