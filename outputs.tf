output "diagnostic_setting_ids" {
  description = "Map of logical name to the diagnostic setting id."
  value       = { for k, d in azurerm_monitor_diagnostic_setting.this : k => d.id }
}

output "diagnostic_setting_names" {
  description = "Map of logical name to the diagnostic setting's actual name (diag-<resource> when not overridden)."
  value       = { for k, d in azurerm_monitor_diagnostic_setting.this : k => d.name }
}

output "diagnostic_settings" {
  description = "Map of logical name to the setting's key attributes (id, name, target, and resolved destinations)."
  value = { for k, d in azurerm_monitor_diagnostic_setting.this : k => {
    id                             = d.id
    name                           = d.name
    target_resource_id             = d.target_resource_id
    log_analytics_workspace_id     = d.log_analytics_workspace_id
    storage_account_id             = d.storage_account_id
    eventhub_name                  = d.eventhub_name
    eventhub_authorization_rule_id = d.eventhub_authorization_rule_id
    partner_solution_id            = d.partner_solution_id
  } }
}
