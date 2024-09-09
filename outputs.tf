output "diagnostic_setting_id" {
  description = "The ID of the diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.diagnostic_settings != null && length(azurerm_monitor_diagnostic_setting.diagnostic_settings) > 0 ? azurerm_monitor_diagnostic_setting.diagnostic_settings[0].id : null
}

output "diagnostic_setting_name" {
  description = "The name of the diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.diagnostic_settings != null && length(azurerm_monitor_diagnostic_setting.diagnostic_settings) > 0 ? azurerm_monitor_diagnostic_setting.diagnostic_settings[0].name : null
}

output "eventhub_name" {
  description = "The name of the Event Hub associated with the diagnostic setting."
  value       = try(azurerm_monitor_diagnostic_setting.diagnostic_settings[0].eventhub_name, null)
}

output "log_analytics_workspace_id" {
  description = "The ID of the log analytics workspace associated with the diagnostic setting."
  value       = try(azurerm_monitor_diagnostic_setting.diagnostic_settings[0].log_analytics_workspace_id, null)
}

output "storage_account_id" {
  description = "The ID of the storage account associated with the diagnostic setting."
  value       = try(azurerm_monitor_diagnostic_setting.diagnostic_settings[0].storage_account_id, null)
}

output "target_resource_id" {
  description = "The ID of the resource targeted by the diagnostic setting."
  value       = azurerm_monitor_diagnostic_setting.diagnostic_settings != null && length(azurerm_monitor_diagnostic_setting.diagnostic_settings) > 0 ? azurerm_monitor_diagnostic_setting.diagnostic_settings[0].target_resource_id : null
}
