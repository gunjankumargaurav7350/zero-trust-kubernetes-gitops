terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.90.0"
    }
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# -------------------------------------------------------------------------------------------------
# Modular Zero-Trust AKS Clusters using for_each
# -------------------------------------------------------------------------------------------------
module "aks_clusters" {
  source   = "./modules/aks_cluster"
  for_each = var.aks_clusters

  resource_group_name     = azurerm_resource_group.aks_rg.name
  location                = azurerm_resource_group.aks_rg.location
  cluster_name            = each.key
  dns_prefix              = each.value.dns_prefix
  kubernetes_version      = each.value.kubernetes_version
  private_cluster_enabled = each.value.private_cluster_enabled
  node_count              = each.value.node_count
  node_vm_size            = each.value.node_vm_size
  aks_subnet_id           = each.value.aks_subnet_id
  environment             = each.value.environment
  additional_node_pools   = each.value.additional_node_pools
  tags                    = merge(azurerm_resource_group.aks_rg.tags, each.value.tags)
}

# -------------------------------------------------------------------------------------------------
# Modular Entra ID Workload Identity with Federated Credentials
# -------------------------------------------------------------------------------------------------
module "workload_identity" {
  source = "./modules/workload_identity"

  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  oidc_issuer_url     = module.aks_clusters[var.primary_cluster_key].oidc_issuer_url
  identities          = var.workload_identities
}
