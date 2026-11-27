output "enabled_plans" {
  description = "Defender plans enabled at the Standard tier."
  value       = keys(azurerm_security_center_subscription_pricing.this)
}
