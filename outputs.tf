output "diagnostic_setting_ids" {
  description = "Map of logical name to the diagnostic setting id."
  value       = { for k, d in azurerm_monitor_diagnostic_setting.this : k => d.id }
}

output "diagnostic_setting_names" {
  description = "Map of logical name to the diagnostic setting's actual name (diag-<resource> when not overridden)."
  value       = { for k, d in azurerm_monitor_diagnostic_setting.this : k => d.name }
}

output "diagnostic_settings" {
  description = "The full azurerm_monitor_diagnostic_setting resources, keyed by logical name."
  value       = azurerm_monitor_diagnostic_setting.this
}
