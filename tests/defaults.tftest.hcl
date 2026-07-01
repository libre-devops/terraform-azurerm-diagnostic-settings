# Plan-time tests for the module. The azurerm provider is mocked, so no credentials, no
# features block, and no cloud calls are needed:
#   terraform init -backend=false && terraform test

mock_provider "azurerm" {}

variables {
  # Module-level default destination: every setting ships here unless it overrides.
  log_analytics_workspace_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.OperationalInsights/workspaces/log-ldo-uks-tst-001"

  diagnostic_settings = {
    "vnet" = { target_resource_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet-ldo-uks-tst-001" }
  }
}

run "ships_all_logs_and_metrics_by_default" {
  command = plan

  assert {
    condition     = length(azurerm_monitor_diagnostic_setting.this["vnet"].enabled_log) == 1 && one(azurerm_monitor_diagnostic_setting.this["vnet"].enabled_log).category_group == "allLogs"
    error_message = "By default a setting should enable all logs via the allLogs category group."
  }

  assert {
    condition     = one(azurerm_monitor_diagnostic_setting.this["vnet"].enabled_metric).category == "AllMetrics"
    error_message = "By default a setting should enable all metrics via AllMetrics."
  }
}

run "name_defaults_to_diag_prefix_and_destination_inherited" {
  command = plan

  assert {
    condition     = azurerm_monitor_diagnostic_setting.this["vnet"].name == "diag-vnet-ldo-uks-tst-001"
    error_message = "name should default to diag-<target resource name>."
  }

  assert {
    condition     = azurerm_monitor_diagnostic_setting.this["vnet"].log_analytics_workspace_id == var.log_analytics_workspace_id
    error_message = "The setting should inherit the module-level Log Analytics workspace default."
  }
}

run "explicit_categories_when_all_disabled" {
  command = plan

  variables {
    diagnostic_settings = {
      "kv" = {
        target_resource_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.KeyVault/vaults/kv-ldo-uks-tst-001"
        name               = "diag-kv-audit"
        enable_all_logs    = false
        enable_all_metrics = false
        enabled_logs       = [{ category = "AuditEvent" }]
        enabled_metrics    = [{ category = "AllMetrics" }]
      }
    }
  }

  assert {
    condition     = one(azurerm_monitor_diagnostic_setting.this["kv"].enabled_log).category == "AuditEvent" && azurerm_monitor_diagnostic_setting.this["kv"].name == "diag-kv-audit"
    error_message = "With enable_all_logs = false the explicit enabled_logs categories should be used, and an explicit name honoured."
  }
}

run "rejects_log_entry_with_both_category_and_group" {
  command = plan

  variables {
    diagnostic_settings = {
      "bad" = {
        target_resource_id = "/subscriptions/0000/resourceGroups/rg/providers/Microsoft.Network/virtualNetworks/vnet"
        enable_all_logs    = false
        enabled_logs       = [{ category = "AuditEvent", category_group = "allLogs" }]
      }
    }
  }

  expect_failures = [var.diagnostic_settings]
}

run "rejects_invalid_destination_type" {
  command = plan

  variables {
    log_analytics_destination_type = "SomethingElse"
  }

  expect_failures = [var.log_analytics_destination_type]
}
