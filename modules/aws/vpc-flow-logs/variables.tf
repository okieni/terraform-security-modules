variable "vpc_id" {
  description = "ID of the VPC to monitor."
  type        = string
}

variable "traffic_type" {
  description = "ACCEPT, REJECT or ALL."
  type        = string
  default     = "ALL"

  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.traffic_type)
    error_message = "Must be ACCEPT, REJECT or ALL."
  }
}

variable "retention_in_days" {
  description = "How long to keep flow logs."
  type        = number
  default     = 365
}

variable "kms_key_arn" {
  description = "KMS key for the log group. Its policy must allow logs.<region>.amazonaws.com."
  type        = string
  default     = null
}

variable "max_aggregation_interval" {
  description = "Aggregation interval in seconds: 60 or 600."
  type        = number
  default     = 60
}

variable "restrict_default_security_group" {
  description = "Strip all rules from the VPC's default security group."
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags applied to all resources."
  type        = map(string)
  default     = {}
}
