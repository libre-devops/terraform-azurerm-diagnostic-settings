variable "diagnostic_settings" {
  description = <<-EOT
    Diagnostic settings to create, keyed by a logical name. The only required field per entry is
    target_resource_id; the destination falls back to the module-level defaults, and by default every
    setting ships ALL logs and ALL metrics (enable_all_logs / enable_all_metrics), so the minimal entry
    is just { target_resource_id = <id> }.

    name defaults to diag-<target resource name>. To select specific categories, set enable_all_logs =
    false and list enabled_logs (each with category OR category_group), and/or enable_all_metrics =
    false with enabled_metrics.
  EOT
  type = map(object({
    target_resource_id = string
    name               = optional(string)

    log_analytics_workspace_id     = optional(string)
    log_analytics_destination_type = optional(string)
    storage_account_id             = optional(string)
    eventhub_name                  = optional(string)
    eventhub_authorization_rule_id = optional(string)
    partner_solution_id            = optional(string)

    enable_all_logs    = optional(bool, true)
    enable_all_metrics = optional(bool, true)
    enabled_logs = optional(list(object({
      category       = optional(string)
      category_group = optional(string)
    })), [])
    enabled_metrics = optional(list(object({
      category = string
    })), [])
  }))
  default = {}

  validation {
    condition = alltrue([
      for ds in values(var.diagnostic_settings) : alltrue([
        for l in ds.enabled_logs : (l.category != null) != (l.category_group != null)
      ])
    ])
    error_message = "Each enabled_logs entry must set exactly one of category or category_group."
  }
}

variable "eventhub_authorization_rule_id" {
  description = "Default event hub authorization rule id for streaming diagnostics. Inherited by any setting that does not set its own."
  type        = string
  default     = null
}

variable "eventhub_name" {
  description = "Default event hub name to stream diagnostics to (requires eventhub_authorization_rule_id). Inherited by any setting that does not set its own."
  type        = string
  default     = null
}

variable "log_analytics_destination_type" {
  description = "Default log_analytics_destination_type: Dedicated (resource-specific tables, recommended) or AzureDiagnostics (single legacy table)."
  type        = string
  default     = null

  validation {
    condition     = var.log_analytics_destination_type == null || contains(["Dedicated", "AzureDiagnostics"], coalesce(var.log_analytics_destination_type, "Dedicated"))
    error_message = "log_analytics_destination_type must be Dedicated or AzureDiagnostics."
  }
}

variable "log_analytics_workspace_id" {
  description = "Default Log Analytics workspace id to send diagnostics to. Inherited by any setting that does not set its own."
  type        = string
  default     = null
}

variable "partner_solution_id" {
  description = "Default partner solution (Azure Native ISV) id to send diagnostics to. Inherited by any setting that does not set its own."
  type        = string
  default     = null
}

variable "storage_account_id" {
  description = "Default storage account id to archive diagnostics to. Inherited by any setting that does not set its own."
  type        = string
  default     = null
}
