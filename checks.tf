# check blocks run after every plan and apply and emit a warning (without blocking) when an
# invariant is violated. They are the place to enforce module-wide consistency.

# Every diagnostic setting needs at least one destination (Azure rejects a setting with none). This
# checks the resolved destinations (per-setting value or the module-level default), so it catches the
# common mistake of forgetting to set any destination.
check "every_setting_has_a_destination" {
  assert {
    condition = alltrue([
      for ds in values(local.diagnostic_settings) :
      ds.log_analytics_workspace_id != null || ds.storage_account_id != null || ds.eventhub_authorization_rule_id != null || ds.partner_solution_id != null
    ])
    error_message = "Every diagnostic setting must resolve to at least one destination (log_analytics_workspace_id, storage_account_id, eventhub_authorization_rule_id, or partner_solution_id) either on the setting or as a module-level default."
  }
}
