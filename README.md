```hcl
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
```
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.diagnostic_settings](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | An object containing the diagnostic settings for a resource | <pre>object({<br>    diagnostic_settings_name       = optional(string)<br>    target_resource_id             = string<br>    storage_account_id             = optional(string)<br>    eventhub_name                  = optional(string)<br>    eventhub_authorization_rule_id = optional(string)<br>    law_id                         = optional(string)<br>    law_destination_type           = optional(string, "Dedicated")<br>    partner_solution_id            = optional(string)<br>    enabled_log = optional(list(object({<br>      category       = optional(string)<br>      category_group = optional(string)<br>    })), [])<br>    metric = optional(list(object({<br>      category = string<br>      enabled  = optional(bool, true)<br>    })), [])<br>    enable_all_logs    = optional(bool, false)<br>    enable_all_metrics = optional(bool, false)<br>  })</pre> | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_setting_id"></a> [diagnostic\_setting\_id](#output\_diagnostic\_setting\_id) | The ID of the diagnostic setting. |
| <a name="output_diagnostic_setting_name"></a> [diagnostic\_setting\_name](#output\_diagnostic\_setting\_name) | The name of the diagnostic setting. |
| <a name="output_eventhub_name"></a> [eventhub\_name](#output\_eventhub\_name) | The name of the Event Hub associated with the diagnostic setting. |
| <a name="output_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#output\_log\_analytics\_workspace\_id) | The ID of the log analytics workspace associated with the diagnostic setting. |
| <a name="output_storage_account_id"></a> [storage\_account\_id](#output\_storage\_account\_id) | The ID of the storage account associated with the diagnostic setting. |
| <a name="output_target_resource_id"></a> [target\_resource\_id](#output\_target\_resource\_id) | The ID of the resource targeted by the diagnostic setting. |
