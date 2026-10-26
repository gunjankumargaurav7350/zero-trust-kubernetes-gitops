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
# Zero-Trust Production AKS Cluster with Cilium eBPF Data Plane & Workload Identity
# -------------------------------------------------------------------------------------------------
resource "azurerm_kubernetes_cluster" "zero_trust_aks" {
  name                              = var.cluster_name
  location                          = azurerm_resource_group.aks_rg.location
  resource_group_name               = azurerm_resource_group.aks_rg.name
  dns_prefix                        = var.dns_prefix
  kubernetes_version                = var.kubernetes_version
  private_cluster_enabled           = var.private_cluster_enabled
  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  role_based_access_control_enabled = true

  default_node_pool {
    name                = "syspool"
    node_count          = var.node_count
    vm_size             = var.node_vm_size
    vnet_subnet_id      = var.aks_subnet_id
    zones               = ["1", "2", "3"]
    enable_auto_scaling = true
    min_count           = 3
    max_count           = 10
    os_disk_type        = "Ephemeral"
    os_disk_size_gb     = 64
    type                = "VirtualMachineScaleSets"

    node_labels = {
      "nodepool"    = "system"
      "environment" = var.environment
    }

    tags = var.tags
  }

  identity {
    type = "SystemAssigned"
  }

  # Azure CNI Overlay powered by Cilium eBPF for Zero-Trust L7 Network Security
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    network_data_plane  = "cilium"
    load_balancer_sku   = "standard"
    outbound_type       = "userDefinedRouting" # All egress routed via central Azure Firewall
  }

  # Secret Store CSI Driver: Mount Key Vault secrets directly into RAM (zero secrets in etcd)
  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = var.tags
}
