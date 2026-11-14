variable "resource_group_name" {
  type    = string
  default = "rg-aks-zerotrust-prod"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "tags" {
  type = map(string)
  default = {
    Environment = "Production"
    Platform    = "ZeroTrust-Kubernetes"
    ManagedBy   = "Terraform"
    GitOps      = "ArgoCD"
    Owner       = "Gunjan Kumar Gaurav"
  }
}

variable "primary_cluster_key" {
  type        = string
  description = "Key of the primary AKS cluster used for Workload Identity federation"
  default     = "aks-zerotrust-prod-01"
}

variable "aks_clusters" {
  type = map(object({
    dns_prefix              = string
    kubernetes_version      = optional(string, "1.30.2")
    private_cluster_enabled = optional(bool, true)
    node_count              = optional(number, 3)
    node_vm_size            = optional(string, "Standard_D4ds_v5")
    aks_subnet_id           = optional(string, null)
    environment             = optional(string, "production")
    tags                    = optional(map(string), {})
    additional_node_pools   = optional(map(object({
      vm_size             = string
      node_count          = optional(number, 3)
      enable_auto_scaling = optional(bool, true)
      min_count           = optional(number, 1)
      max_count           = optional(number, 10)
      os_disk_type        = optional(string, "Ephemeral")
      os_disk_size_gb     = optional(number, 64)
      vnet_subnet_id      = optional(string, null)
      node_labels         = optional(map(string), {})
      tags                = optional(map(string), {})
    })), {})
  }))
  description = "Map of Zero-Trust AKS clusters iterated via for_each"
  default = {
    "aks-zerotrust-prod-01" = {
      dns_prefix              = "aks-zt-prod"
      kubernetes_version      = "1.30.2"
      private_cluster_enabled = true
      node_count              = 3
      node_vm_size            = "Standard_D4ds_v5"
      environment             = "production"
    }
  }
}

variable "workload_identities" {
  type = map(object({
    subject  = string
    audience = optional(list(string), ["api://AzureADTokenExchange"])
    tags     = optional(map(string), {})
  }))
  description = "Map of user assigned identities and federated credentials managed via for_each"
  default = {
    "uai-k8s-payment-prod" = {
      subject  = "system:serviceaccount:payments:payment-service-sa"
      audience = ["api://AzureADTokenExchange"]
    }
  }
}
