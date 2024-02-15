locals {
  // Dynamically include "AllLogs" if enable_all_logs is true, ensuring all expected attributes are present
  adjusted_enabled_log = var.enable_all_logs ? tolist(concat(var.enabled_log, [{
    category         = null,
    category_group   = "allLogs", // Set to null or default as it's optional
    retention_policy = null  // Explicitly set to null if you want to maintain structure without using it
  }])) : var.enabled_log

  // Dynamically include "AllMetrics" if enable_all_metrics is true, ensuring all expected attributes are present
  adjusted_metric = var.enable_all_metrics ? tolist(concat(var.metric, [{
    category         = "AllMetrics",
    enabled          = true, // Explicitly setting 'enabled'
    retention_policy = null  // Explicitly set to null if you want to maintain structure without using it
  }])) : var.metric
}
