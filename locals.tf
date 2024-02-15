locals {
  // Dynamically include "AllLogs" if enable_all_logs is true, otherwise use user-defined configurations
  adjusted_enabled_log = var.enable_all_logs ? concat(var.enabled_log, [
    {
      category = "AllLogs"
      enabled  = true
    }
  ]) : var.enabled_log

  // Dynamically include "AllMetrics" if enable_all_metrics is true, otherwise use user-defined configurations
  adjusted_metric = var.enable_all_metrics ? concat(var.metric, [
    {
      category = "AllMetrics"
      enabled  = true
    }
  ]) : var.metric
}
