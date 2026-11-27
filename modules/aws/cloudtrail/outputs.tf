output "trail_arn" {
  description = "ARN of the trail."
  value       = aws_cloudtrail.this.arn
}

output "bucket_name" {
  description = "Name of the log bucket."
  value       = module.log_bucket.bucket_id
}

output "cloudwatch_log_group_name" {
  description = "CloudWatch log group name, if enabled."
  value       = var.enable_cloudwatch_logs ? aws_cloudwatch_log_group.this[0].name : null
}
