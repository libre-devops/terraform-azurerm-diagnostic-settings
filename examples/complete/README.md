<!--
  Header for the complete example README. Edit this file, then run `just docs`
  (or ./Sort-LdoTerraform.ps1 -IncludeExamples) to regenerate the section between the markers.
  The example's main.tf is embedded into the README automatically (see .terraform-docs.yml).
-->
<div align="center">
  <a href="https://libredevops.org">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="https://libredevops.org/assets/libre-devops-white.png">
      <img alt="Libre DevOps" src="https://libredevops.org/assets/libre-devops-black.png" width="200">
    </picture>
  </a>
</div>

# Complete example

Exercises the fuller surface of this module. The environment comes from the Terraform workspace
(`terraform.workspace`), not a variable. Run it with `just e2e complete`, which applies the stack
then always destroys it.

[![Terraform Registry](https://img.shields.io/badge/registry-libre--devops-7B42BC?logo=terraform&logoColor=white)](https://registry.terraform.io/namespaces/libre-devops)

<!-- BEGIN_TF_DOCS -->
## Example configuration

```hcl
locals {
  location = lookup(var.regions, var.loc, "uksouth")
  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-002"
  law_name = "log-${var.short}-${var.loc}-${terraform.workspace}-002"
  kv_name  = "kv-${var.short}-${var.loc}-${terraform.workspace}-002"
  pip_name = "pip-${var.short}-${var.loc}-${terraform.workspace}-002"
}

data "azurerm_client_config" "current" {}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  environment     = "prd"
  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
  additional_tags = { Application = "terraform-azurerm-diagnostic-settings" }
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

# Destination workspace.
module "log_analytics" {
  source  = "libre-devops/log-analytics-workspace/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  log_analytics_workspaces = { (local.law_name) = {} }
}

# Two different target resources to diagnose.
resource "azurerm_key_vault" "this" {
  name                = local.kv_name
  location            = local.location
  resource_group_name = module.rg.names[local.rg_name]
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = module.tags.tags

  # Deny by default (Azure services may bypass). Purge protection is intentionally left off so this
  # disposable example vault can be torn down (see the Trivy waiver for AZU-0016).
  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }
}

module "public_ip" {
  source  = "libre-devops/public-ip/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  public_ips = { (local.pip_name) = {} }
}

# Complete call: the module-level workspace is the default destination, so most settings are one line.
# It shows several targets at once, a metrics-only setting (logs disabled), and a second setting on the
# same resource that ships only a specific log category.
module "diagnostics" {
  source = "../../"

  log_analytics_workspace_id     = module.log_analytics.workspace_ids[local.law_name]
  log_analytics_destination_type = "Dedicated"

  diagnostic_settings = {
    # All logs and metrics (the easy default), name auto-derived to diag-<kv name>.
    "kv" = {
      target_resource_id = azurerm_key_vault.this.id
    }

    # A public IP has metrics but no general logs, so ship metrics only.
    "pip" = {
      target_resource_id = module.public_ip.public_ip_ids[local.pip_name]
      enable_all_logs    = false
    }

    # A second setting on the Key Vault that ships only the audit log category, with an explicit name.
    "kv-audit" = {
      target_resource_id = azurerm_key_vault.this.id
      name               = "diag-kv-audit"
      enable_all_logs    = false
      enable_all_metrics = false
      enabled_logs       = [{ category = "AuditEvent" }]
    }
  }
}
```

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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_diagnostics"></a> [diagnostics](#module\_diagnostics) | ../../ | n/a |
| <a name="module_log_analytics"></a> [log\_analytics](#module\_log\_analytics) | libre-devops/log-analytics-workspace/azurerm | ~> 4.0 |
| <a name="module_public_ip"></a> [public\_ip](#module\_public\_ip) | libre-devops/public-ip/azurerm | ~> 4.0 |
| <a name="module_rg"></a> [rg](#module\_rg) | libre-devops/rg/azurerm | ~> 4.0 |
| <a name="module_tags"></a> [tags](#module\_tags) | libre-devops/tags/azurerm | ~> 4.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_key_vault.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_deployed_branch"></a> [deployed\_branch](#input\_deployed\_branch) | Git branch the deployment came from. Auto-filled in CI from TF\_VAR\_deployed\_branch. | `string` | `""` | no |
| <a name="input_deployed_repo"></a> [deployed\_repo](#input\_deployed\_repo) | Repository URL the deployment came from. Auto-filled in CI from TF\_VAR\_deployed\_repo. | `string` | `""` | no |
| <a name="input_loc"></a> [loc](#input\_loc) | Outfix: short Azure region code used in resource names (for example uks). | `string` | `"uks"` | no |
| <a name="input_regions"></a> [regions](#input\_regions) | Map of short region codes to Azure region slugs. | `map(string)` | <pre>{<br/>  "eus": "eastus",<br/>  "euw": "westeurope",<br/>  "uks": "uksouth",<br/>  "ukw": "ukwest"<br/>}</pre> | no |
| <a name="input_short"></a> [short](#input\_short) | Infix: short product code used in resource names. | `string` | `"ldo"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_diagnostic_setting_ids"></a> [diagnostic\_setting\_ids](#output\_diagnostic\_setting\_ids) | The diagnostic setting ids. |
| <a name="output_diagnostic_setting_names"></a> [diagnostic\_setting\_names](#output\_diagnostic\_setting\_names) | The diagnostic setting names. |
| <a name="output_tags"></a> [tags](#output\_tags) | The tags applied to the resources. |
<!-- END_TF_DOCS -->
