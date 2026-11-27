variable "name" {
  description = "Name of the trail."
  type        = string
  default     = "org-security-trail"
}

variable "bucket_name" {
  description = "Name of the S3 bucket created to store the logs."
  type        = string
}

variable "kms_key_arn" {
  description = "KMS key ARN to encrypt logs. The key policy must allow cloudtrail.amazonaws.com (see the kms-key module). Strongly recommended."
  type        = string
  default     = null
}

variable "access_log_bucket" {
  description = "Bucket to receive S3 access logs for the trail bucket."
  type        = string
  default     = null
}

variable "enable_cloudwatch_logs" {
  description = "Also send events to CloudWatch Logs so alarms can be built on them."
  type        = bool
  default     = true
}

variable "cloudwatch_retention_days" {
  description = "Retention for the CloudWatch log group."
  type        = number
  default     = 365
}

variable "log_s3_data_events" {
  description = "Record S3 object-level (data) events for all buckets. Adds cost."
  type        = bool
  default     = false
}

variable "is_organization_trail" {
  description = "Create an organization trail (must run in the management or delegated admin account)."
  type        = bool
  default     = false
}

variable "force_destroy" {
  description = "Allow deleting the log bucket with objects inside. Keep false outside labs."
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
