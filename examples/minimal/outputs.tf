output "diagnostic_setting_ids" {
  description = "The diagnostic setting ids."
  value       = module.diagnostics.diagnostic_setting_ids
}

output "diagnostic_setting_names" {
  description = "The diagnostic setting names (diag-<resource> when auto-derived)."
  value       = module.diagnostics.diagnostic_setting_names
}
