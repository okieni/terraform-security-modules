output "workspace_id" {
  description = "Resource ID of the Log Analytics workspace (pass to other modules' log_analytics_workspace_id)."
  value       = local.workspace_id
}

output "action_group_id" {
  description = "ID of the security alerts action group, if created."
  value       = length(var.alert_emails) > 0 ? azurerm_monitor_action_group.this[0].id : null
}
