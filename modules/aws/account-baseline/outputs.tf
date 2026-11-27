output "access_analyzer_arn" {
  description = "ARN of the Access Analyzer, if created."
  value       = var.enable_access_analyzer ? aws_accessanalyzer_analyzer.this[0].arn : null
}

output "security_hub_standards" {
  description = "Security Hub standards subscribed."
  value       = [for s in aws_securityhub_standards_subscription.this : s.standards_arn]
}
