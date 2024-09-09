```hcl
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
| <a name="input_diagnostic_settings_name"></a> [diagnostic\_settings\_name](#input\_diagnostic\_settings\_name) | The name of the diagnostic settings | `string` | `null` | no |
| <a name="input_enable_all_logs"></a> [enable\_all\_logs](#input\_enable\_all\_logs) | Whether the allLogs category is enabled | `bool` | `true` | no |
| <a name="input_enable_all_metrics"></a> [enable\_all\_metrics](#input\_enable\_all\_metrics) | Whether the AllMetric category is enabled | `bool` | `true` | no |
| <a name="input_enabled_log"></a> [enabled\_log](#input\_enabled\_log) | The enabled\_log blocks | <pre>list(object({<br>    category       = optional(string)<br>    category_group = optional(string)<br>    retention_policy = optional(object({<br>      enabled = optional(bool)<br>      days    = optional(number)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_eventhub_authorization_rule_id"></a> [eventhub\_authorization\_rule\_id](#input\_eventhub\_authorization\_rule\_id) | The rule id of the eventhub, if used | `string` | `null` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | The name of the eventhub, if used | `string` | `null` | no |
| <a name="input_law_destination_type"></a> [law\_destination\_type](#input\_law\_destination\_type) | Destination type for log analytics | `string` | `null` | no |
| <a name="input_law_id"></a> [law\_id](#input\_law\_id) | The ID of a log analytics workspace, if used | `string` | `null` | no |
| <a name="input_log"></a> [log](#input\_log) | The log blocks, which are deprecated | <pre>list(object({<br>    category       = optional(string)<br>    category_group = optional(string)<br>    enabled        = optional(bool)<br>    retention_policy = optional(object({<br>      enabled = optional(bool)<br>      days    = optional(number)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_metric"></a> [metric](#input\_metric) | The metric blocks | <pre>list(object({<br>    category = optional(string)<br>    enabled  = optional(bool)<br>    retention_policy = optional(object({<br>      enabled = optional(bool)<br>      days    = optional(number)<br>    }))<br>  }))</pre> | `[]` | no |
| <a name="input_partner_solution_id"></a> [partner\_solution\_id](#input\_partner\_solution\_id) | The id of a partnter solution, if used | `string` | `null` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | The ID of a storage account to send logs to, if used | `string` | `null` | no |
| <a name="input_target_resource_id"></a> [target\_resource\_id](#input\_target\_resource\_id) | The ID of the resource for diagnostic settings | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_settings_id"></a> [diagnostic\_settings\_id](#output\_diagnostic\_settings\_id) | The ID of the diagnostic settings |
