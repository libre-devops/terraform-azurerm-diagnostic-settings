resource "azurerm_monitor_diagnostic_setting" "diagnostic_settings" {
  count = var.diagnostic_settings != null ? 1 : 0

  name                           = local.diagnostic_setting_name
  target_resource_id             = var.diagnostic_settings.target_resource_id
  storage_account_id             = try(var.diagnostic_settings.storage_account_id, null)
  eventhub_name                  = try(var.diagnostic_settings.eventhub_name, null)
  eventhub_authorization_rule_id = try(var.diagnostic_settings.eventhub_authorization_rule_id, null)
  log_analytics_workspace_id     = try(var.diagnostic_settings.law_id, null)
  log_analytics_destination_type = try(var.diagnostic_settings.law_destination_type, null)
  partner_solution_id            = try(var.diagnostic_settings.partner_solution_id, null)

  dynamic "enabled_log" {
    for_each = local.adjusted_enabled_log != [] ? toset(local.adjusted_enabled_log) : []
    content {
      category       = enabled_log.value.category
      category_group = try(enabled_log.value.category_group, null)
    }
  }

  dynamic "metric" {
    for_each = local.adjusted_metric != [] ? toset(local.adjusted_metric) : []
    content {
      category = metric.value.category
      enabled  = metric.value.enabled
    }
  }
}
