locals {
  # Resolve each diagnostic setting: fill destinations from the module-level defaults where a setting
  # does not override them, derive a diag-<resource> name when none is given, and expand the
  # enable_all_logs / enable_all_metrics convenience flags into concrete blocks. This is what makes the
  # module easy: give a target and a destination (often just once at module level) and everything ships.
  diagnostic_settings = {
    for k, ds in var.diagnostic_settings : k => {
      target_resource_id = ds.target_resource_id
      name               = coalesce(ds.name, "diag-${element(split("/", ds.target_resource_id), length(split("/", ds.target_resource_id)) - 1)}")

      log_analytics_workspace_id     = try(coalesce(ds.log_analytics_workspace_id, var.log_analytics_workspace_id), null)
      log_analytics_destination_type = try(coalesce(ds.log_analytics_destination_type, var.log_analytics_destination_type), null)
      storage_account_id             = try(coalesce(ds.storage_account_id, var.storage_account_id), null)
      eventhub_name                  = try(coalesce(ds.eventhub_name, var.eventhub_name), null)
      eventhub_authorization_rule_id = try(coalesce(ds.eventhub_authorization_rule_id, var.eventhub_authorization_rule_id), null)
      partner_solution_id            = try(coalesce(ds.partner_solution_id, var.partner_solution_id), null)

      # allLogs is the category group that ships every log category without listing them.
      logs = ds.enable_all_logs ? [{ category = null, category_group = "allLogs" }] : [
        for l in ds.enabled_logs : { category = l.category, category_group = l.category_group }
      ]
      metrics = ds.enable_all_metrics ? ["AllMetrics"] : [for m in ds.enabled_metrics : m.category]
    }
  }
}
