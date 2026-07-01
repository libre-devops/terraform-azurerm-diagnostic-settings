# Diagnostic settings for any set of Azure resources, keyed by name. Point each setting at a target
# resource and a destination (Log Analytics, storage, event hub, or a partner solution); set the
# destination once at module level and every setting inherits it. By default (enable_all_logs /
# enable_all_metrics) each setting ships ALL logs and ALL metrics, so the minimal input is just a
# target id. Names default to diag-<resource>. Diagnostic settings have no resource group, location,
# or tags of their own, so this module has none either.

resource "azurerm_monitor_diagnostic_setting" "this" {
  for_each = local.diagnostic_settings

  name               = each.value.name
  target_resource_id = each.value.target_resource_id

  log_analytics_workspace_id     = each.value.log_analytics_workspace_id
  log_analytics_destination_type = each.value.log_analytics_destination_type
  storage_account_id             = each.value.storage_account_id
  eventhub_name                  = each.value.eventhub_name
  eventhub_authorization_rule_id = each.value.eventhub_authorization_rule_id
  partner_solution_id            = each.value.partner_solution_id

  dynamic "enabled_log" {
    for_each = each.value.logs

    content {
      category       = enabled_log.value.category
      category_group = enabled_log.value.category_group
    }
  }

  dynamic "enabled_metric" {
    for_each = each.value.metrics

    content {
      category = enabled_metric.value
    }
  }
}
