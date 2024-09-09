variable "diagnostic_settings" {
  description = "An object containing the diagnostic settings for a resource"
  type = object({
    diagnostic_settings_name       = optional(string)
    target_resource_id             = string
    storage_account_id             = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    law_id                         = optional(string)
    law_destination_type           = optional(string)
    partner_solution_id            = optional(string)
    enabled_log = optional(list(object({
      category       = string
      category_group = optional(string)
    })), [])
    metric = optional(list(object({
      category = string
      enabled  = optional(bool, true)
    })), [])
    enable_all_logs    = optional(bool, false)
    enable_all_metrics = optional(bool, false)
  })
}
