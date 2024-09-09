locals {
  // Dynamically include "AllLogs" if enable_all_logs is true
  adjusted_enabled_log = var.diagnostic_settings.enable_all_logs ? tolist(concat(var.diagnostic_settings.enabled_log, [{
    category         = null,
    category_group   = "allLogs", // Set to "allLogs" for including all logs
    retention_policy = null       // Retain the structure with null if needed
  }])) : var.diagnostic_settings.enabled_log

  // Dynamically include "AllMetrics" if enable_all_metrics is true
  adjusted_metric = var.diagnostic_settings.enable_all_metrics ? tolist(concat(var.diagnostic_settings.metric, [{
    category         = "AllMetrics", // Include "AllMetrics" category
    enabled          = true,         // Explicitly set 'enabled' to true
    retention_policy = null          // Retain structure with null if needed
  }])) : var.diagnostic_settings.metric

  split_target_resource_id = split("/", var.diagnostic_settings.target_resource_id)
  resource_name_from_id    = element(local.split_target_resource_id, length(local.split_target_resource_id) - 1)

  # Use the extracted resource name followed by "diagnostics" if var.diagnostic_settings.diagnostic_settings_name is null
  diagnostic_setting_name = var.diagnostic_settings.diagnostic_settings_name != null ? var.diagnostic_settings.diagnostic_settings_name : "${local.resource_name_from_id}-diagnostics"
}

