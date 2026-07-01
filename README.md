<!--
  Keep the title and badges OUTSIDE the centered <div>: the Terraform Registry's markdown renderer
  does not parse markdown inside an HTML block, so a # heading or [![badge]] in the div renders as
  literal text on the registry. Only the logo (HTML) goes in the div.
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="300">
    </picture>
  </a>
</div>

# Terraform Azure Diagnostic Settings

Ship any resource's logs and metrics to Log Analytics, storage, an event hub, or a partner solution.

[![CI](https://github.com/libre-devops/terraform-azurerm-diagnostic-settings/actions/workflows/ci.yml/badge.svg)](https://github.com/libre-devops/terraform-azurerm-diagnostic-settings/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/libre-devops/terraform-azurerm-diagnostic-settings?sort=semver&label=release)](https://github.com/libre-devops/terraform-azurerm-diagnostic-settings/releases/latest)
[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)
[![License](https://img.shields.io/github/license/libre-devops/terraform-azurerm-diagnostic-settings)](./LICENSE)

---

## Overview

Diagnostic settings, made trivially easy: `diagnostic_settings` is a `map(object)` keyed by a logical
name, and the only required field per entry is `target_resource_id`. Set the destination **once** at
module level (`log_analytics_workspace_id`, `storage_account_id`, an event hub, or a partner solution)
and every setting inherits it, and by default (`enable_all_logs` / `enable_all_metrics`) each setting
ships **all** logs and **all** metrics. So pointing a dozen resources at a workspace is a dozen
one-liners. Names default to `diag-<target resource>`; set specific `enabled_logs` /`enabled_metrics`
when you need finer control. Diagnostic settings have no resource group, location, or tags.

## Usage

```hcl
module "diagnostics" {
  source  = "libre-devops/diagnostic-settings/azurerm"
  version = "~> 4.0"

  # Set the destination once; every setting below ships here.
  log_analytics_workspace_id = module.log_analytics.workspace_ids["log-ldo-uks-prd-001"]

  diagnostic_settings = {
    "vnet" = { target_resource_id = module.network.vnet_id }
    "nsg"  = { target_resource_id = module.nsg.id }
    "kv"   = { target_resource_id = module.key_vault.id }
  }
}
```

## Examples

- [`examples/minimal`](./examples/minimal) - one target (a Key Vault) shipping all logs and metrics to
  a workspace via the module-level default.
- [`examples/complete`](./examples/complete) - several targets at once (Key Vault and a public IP) with
  a shared default workspace, a metrics-only setting, and a second setting shipping a single log
  category.

## Developing

Local work needs **PowerShell 7+** and **[`just`](https://github.com/casey/just)**, because the recipes
wrap the [LibreDevOpsHelpers](https://www.powershellgallery.com/packages/LibreDevOpsHelpers)
PowerShell module (the same engine the `libre-devops/terraform-azure` action runs in CI). Install
just with `brew install just`, or `uv tool add rust-just` then `uv run just <recipe>`.

Run `just` to list recipes: `just update-ldo-pwsh` (install or force-update LibreDevOpsHelpers from
PSGallery), `just validate`, `just scan` (Trivy only), `just pwsh-analyze` (PSScriptAnalyzer only),
`just plan`, `just apply`, `just destroy`, `just e2e`, `just test`, and `just docs` (the
plan/apply/destroy recipes mirror the action, including the storage firewall dance; `just e2e`
applies an example then always destroys it, defaulting to `minimal`, so nothing is left running).
Releasing is also `just`:
`just increment-release [patch|minor|major]` bumps, tags, and publishes a GitHub release, and the
Terraform Registry picks up the tag.

## Security scan exceptions

This module is scanned with [Trivy](https://github.com/aquasecurity/trivy); HIGH and CRITICAL
findings fail the build. Any waiver is a deliberate, reviewed decision, never a way to quiet a
finding that should be fixed. Waivers live in [`.trivyignore.yaml`](./.trivyignore.yaml) (the
machine-applied source of truth, passed to Trivy with `--ignorefile`) and are mirrored in the table
below so the reason is auditable.

| Trivy ID | Resource | Finding | Justification |
|----------|----------|---------|---------------|
| AVD-AZU-0016 | Example Key Vault (`examples/*/main.tf`) | Purge protection not enabled | The example vault is a disposable diagnostic target; purge protection is left off so the self-test can tear it down. Real vaults use the Libre DevOps key-vault module (purge protection on). |

To add an exception: add an entry to `.trivyignore.yaml` (`id`, optional `paths` to scope it, and a
`statement` recording why), then add a matching row here. Where the finding is out of this module's
scope, point the justification at the Libre DevOps module that does address it (for example the
private-endpoint module). Both the file and this table are reviewed in the pull request.

## Reference

The Requirements, Providers, Inputs, Outputs, and Resources below are generated by `terraform-docs`.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0, < 2.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 4.0.0, < 5.0.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 4.0.0, < 5.0.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Diagnostic settings to create, keyed by a logical name. The only required field per entry is<br/>target\_resource\_id; the destination falls back to the module-level defaults, and by default every<br/>setting ships ALL logs and ALL metrics (enable\_all\_logs / enable\_all\_metrics), so the minimal entry<br/>is just { target\_resource\_id = <id> }.<br/><br/>name defaults to diag-<target resource name>. To select specific categories, set enable\_all\_logs =<br/>false and list enabled\_logs (each with category OR category\_group), and/or enable\_all\_metrics =<br/>false with enabled\_metrics. | <pre>map(object({<br/>    target_resource_id = string<br/>    name               = optional(string)<br/><br/>    log_analytics_workspace_id     = optional(string)<br/>    log_analytics_destination_type = optional(string)<br/>    storage_account_id             = optional(string)<br/>    eventhub_name                  = optional(string)<br/>    eventhub_authorization_rule_id = optional(string)<br/>    partner_solution_id            = optional(string)<br/><br/>    enable_all_logs    = optional(bool, true)<br/>    enable_all_metrics = optional(bool, true)<br/>    enabled_logs = optional(list(object({<br/>      category       = optional(string)<br/>      category_group = optional(string)<br/>    })), [])<br/>    enabled_metrics = optional(list(object({<br/>      category = string<br/>    })), [])<br/>  }))</pre> | `{}` | no |
| <a name="input_eventhub_authorization_rule_id"></a> [eventhub\_authorization\_rule\_id](#input\_eventhub\_authorization\_rule\_id) | Default event hub authorization rule id for streaming diagnostics. Inherited by any setting that does not set its own. | `string` | `null` | no |
| <a name="input_eventhub_name"></a> [eventhub\_name](#input\_eventhub\_name) | Default event hub name to stream diagnostics to (requires eventhub\_authorization\_rule\_id). Inherited by any setting that does not set its own. | `string` | `null` | no |
| <a name="input_log_analytics_destination_type"></a> [log\_analytics\_destination\_type](#input\_log\_analytics\_destination\_type) | Default log\_analytics\_destination\_type: Dedicated (resource-specific tables, recommended) or AzureDiagnostics (single legacy table). | `string` | `null` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Default Log Analytics workspace id to send diagnostics to. Inherited by any setting that does not set its own. | `string` | `null` | no |
| <a name="input_partner_solution_id"></a> [partner\_solution\_id](#input\_partner\_solution\_id) | Default partner solution (Azure Native ISV) id to send diagnostics to. Inherited by any setting that does not set its own. | `string` | `null` | no |
| <a name="input_storage_account_id"></a> [storage\_account\_id](#input\_storage\_account\_id) | Default storage account id to archive diagnostics to. Inherited by any setting that does not set its own. | `string` | `null` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_setting_ids"></a> [diagnostic\_setting\_ids](#output\_diagnostic\_setting\_ids) | Map of logical name to the diagnostic setting id. |
| <a name="output_diagnostic_setting_names"></a> [diagnostic\_setting\_names](#output\_diagnostic\_setting\_names) | Map of logical name to the diagnostic setting's actual name (diag-<resource> when not overridden). |
| <a name="output_diagnostic_settings"></a> [diagnostic\_settings](#output\_diagnostic\_settings) | Map of logical name to the setting's key attributes (id, name, target, and resolved destinations). |
<!-- END_TF_DOCS -->
