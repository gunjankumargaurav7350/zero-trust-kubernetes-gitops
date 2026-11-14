resource "azurerm_kubernetes_cluster" "aks" {
  name                              = var.cluster_name
  location                          = var.location
  resource_group_name               = var.resource_group_name
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

  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "overlay"
    network_policy      = "cilium"
    ebpf_data_plane     = "cilium"
    load_balancer_sku   = "standard"
    outbound_type       = "userDefinedRouting"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  tags = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each              = var.additional_node_pools
  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  enable_auto_scaling   = each.value.enable_auto_scaling
  min_count             = each.value.min_count
  max_count             = each.value.max_count
  os_disk_type          = each.value.os_disk_type
  os_disk_size_gb       = each.value.os_disk_size_gb
  vnet_subnet_id        = each.value.vnet_subnet_id
  node_labels           = each.value.node_labels
  tags                  = merge(var.tags, each.value.tags)
}
