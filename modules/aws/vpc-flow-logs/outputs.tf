output "flow_log_id" {
  description = "ID of the flow log."
  value       = aws_flow_log.this.id
}

output "log_group_name" {
  description = "CloudWatch log group receiving the flow logs."
  value       = aws_cloudwatch_log_group.this.name
}
