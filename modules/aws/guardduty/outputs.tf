output "detector_id" {
  description = "ID of the GuardDuty detector."
  value       = aws_guardduty_detector.this.id
}

output "alert_topic_arn" {
  description = "ARN of the SNS alert topic, if enabled."
  value       = var.enable_alerts ? aws_sns_topic.alerts[0].arn : null
}
