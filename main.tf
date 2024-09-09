resource "azurerm_monitor_diagnostic_setting" "diagnostic_settings" {
  name                           = var.diagnostic_settings_name != null ? var.diagnostic_settings_name : "setByPolicy"
  target_resource_id             = var.target_resource_id
  storage_account_id             = var.storage_account_id != null ? var.storage_account_id : null
  eventhub_name                  = var.eventhub_name != null ? var.eventhub_name : null
  eventhub_authorization_rule_id = var.eventhub_name != null && var.eventhub_authorization_rule_id != null ? var.eventhub_authorization_rule_id : null
  log_analytics_workspace_id     = var.law_id != null ? var.law_id : null
  log_analytics_destination_type = var.law_id != null && var.law_destination_type != null ? var.law_destination_type : null
  partner_solution_id            = var.partner_solution_id != null ? var.partner_solution_id : null



  dynamic "enabled_log" {
    for_each = local.adjusted_enabled_log != [] ? toset(local.adjusted_enabled_log) : []
    content {
      category       = enabled_log.value.category
      category_group = enabled_log.value.category_group
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
