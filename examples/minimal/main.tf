locals {
  location = lookup(var.regions, var.loc, "uksouth")
  rg_name  = "rg-${var.short}-${var.loc}-${terraform.workspace}-001"
  law_name = "log-${var.short}-${var.loc}-${terraform.workspace}-001"
  kv_name  = "kv-${var.short}-${var.loc}-${terraform.workspace}-001"
}

data "azurerm_client_config" "current" {}

module "tags" {
  source  = "libre-devops/tags/azurerm"
  version = "~> 4.0"

  cost_centre     = "1888/67"
  owner           = "platform@example.com"
  deployed_branch = var.deployed_branch
  deployed_repo   = var.deployed_repo
}

module "rg" {
  source  = "libre-devops/rg/azurerm"
  version = "~> 4.0"

  resource_groups = [{ name = local.rg_name, location = local.location, tags = module.tags.tags }]
}

# The destination workspace, built by the Libre DevOps log-analytics-workspace module.
module "log_analytics" {
  source  = "libre-devops/log-analytics-workspace/azurerm"
  version = "~> 4.0"

  resource_group_id = module.rg.ids[local.rg_name]
  location          = local.location
  tags              = module.tags.tags

  log_analytics_workspaces = { (local.law_name) = {} }
}

# A target resource to diagnose (Key Vault logs and metrics).
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

# Minimal call: set the destination once, name the target, and every log and metric ships to the
# workspace. That is the whole config.
module "diagnostics" {
  source = "../../"

  log_analytics_workspace_id = module.log_analytics.workspace_ids[local.law_name]

  diagnostic_settings = {
    "kv" = { target_resource_id = azurerm_key_vault.this.id }
  }
}
