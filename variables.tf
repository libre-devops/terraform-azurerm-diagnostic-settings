variable "diagnostic_settings_name" {
  type        = string
  description = "The name of the diagnostic settings"
  default     = null
}

variable "enable_all_logs" {
  type        = bool
  description = "Whether the allLogs category is enabled"
  default     = true
}

variable "enable_all_metrics" {
  type        = bool
  description = "Whether the AllMetric category is enabled"
  default     = true
}

variable "enabled_log" {
  type = list(object({
    category       = optional(string)
    category_group = optional(string)
    retention_policy = optional(object({
      enabled = optional(bool)
      days    = optional(number)
    }))
  }))
  description = "The enabled_log blocks"
  default     = []
}

variable "eventhub_authorization_rule_id" {
  type        = string
  description = "The rule id of the eventhub, if used"
  default     = null
}

variable "eventhub_name" {
  type        = string
  description = "The name of the eventhub, if used"
  default     = null
}

variable "law_destination_type" {
  type        = string
  description = "Destination type for log analytics"
  default = null
}

variable "law_id" {
  type        = string
  description = "The ID of a log analytics workspace, if used"
  default     = null
}

variable "log" {
  type = list(object({
    category       = optional(string)
    category_group = optional(string)
    enabled        = optional(bool)
    retention_policy = optional(object({
      enabled = optional(bool)
      days    = optional(number)
    }))
  }))
  description = "The log blocks, which are deprecated"
  default     = []
}

variable "metric" {
  type = list(object({
    category = optional(string)
    enabled  = optional(bool)
    retention_policy = optional(object({
      enabled = optional(bool)
      days    = optional(number)
    }))
  }))
  description = "The metric blocks"
  default     = []
}

variable "partner_solution_id" {
  type        = string
  description = "The id of a partnter solution, if used"
  default     = null
}

variable "storage_account_id" {
  type        = string
  description = "The ID of a storage account to send logs to, if used"
  default     = null
}

variable "target_resource_id" {
  type        = string
  description = "The ID of the resource for diagnostic settings"
}
