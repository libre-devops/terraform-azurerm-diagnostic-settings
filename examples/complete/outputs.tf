output "diagnostic_setting_ids" {
  description = "The diagnostic setting ids."
  value       = module.diagnostics.diagnostic_setting_ids
}

output "diagnostic_setting_names" {
  description = "The diagnostic setting names."
  value       = module.diagnostics.diagnostic_setting_names
}

output "tags" {
  description = "The tags applied to the resources."
  value       = module.tags.tags
}
