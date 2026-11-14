variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "location" {
  type        = string
  description = "Azure Region"
}

variable "cluster_name" {
  type        = string
  description = "AKS Cluster Name"
}

variable "dns_prefix" {
  type        = string
  description = "DNS Prefix"
}

variable "kubernetes_version" {
  type        = string
  default     = "1.30.2"
}

variable "private_cluster_enabled" {
  type        = bool
  default     = true
}

variable "node_count" {
  type        = number
  default     = 3
}

variable "node_vm_size" {
  type        = string
  default     = "Standard_D4ds_v5"
}

variable "aks_subnet_id" {
  type        = string
  default     = null
}

variable "environment" {
  type        = string
  default     = "production"
}

variable "additional_node_pools" {
  type = map(object({
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
  }))
  description = "Additional user node pools managed using for_each"
  default     = {}
}

variable "tags" {
  type        = map(string)
  default     = {}
}
