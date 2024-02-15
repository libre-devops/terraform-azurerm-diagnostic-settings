output "diagnostic_settings_id" {
  description = "The ID of the diagnostic settings"
  value       = azurerm_monitor_diagnostic_setting.diagnostic_settings.id
}
