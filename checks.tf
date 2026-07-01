# check blocks run after every plan and apply and emit a warning (without blocking) when an
# invariant is violated. They are the place to enforce module-wide consistency.

# Every diagnostic setting must actually ship something: all logs, all metrics, or at least one
# explicit log or metric category. This is knowable at plan time (it reads the config, not the
# resolved destination ids, which are often computed). Note Azure separately rejects a setting with no
# destination at apply, so that failure surfaces there rather than as a plan-time check.
check "every_setting_ships_something" {
  assert {
    condition = alltrue([
      for ds in values(var.diagnostic_settings) :
      ds.enable_all_logs || ds.enable_all_metrics || length(ds.enabled_logs) > 0 || length(ds.enabled_metrics) > 0
    ])
    error_message = "Every diagnostic setting must ship something: keep enable_all_logs/enable_all_metrics on, or set at least one enabled_logs or enabled_metrics entry."
  }
}
