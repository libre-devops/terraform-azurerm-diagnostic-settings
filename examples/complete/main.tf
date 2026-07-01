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
