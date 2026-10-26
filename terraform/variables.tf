variable "resource_group_name" {
  type    = string
  default = "rg-aks-zerotrust-prod"
}

variable "location" {
  type    = string
  default = "eastus"
}

variable "cluster_name" {
  type    = string
  default = "aks-zerotrust-prod-01"
}

variable "dns_prefix" {
  type    = string
  default = "aks-zt-prod"
}

variable "kubernetes_version" {
  type    = string
  default = "1.30.2"
}

variable "private_cluster_enabled" {
  type    = bool
  default = true
}

variable "node_count" {
  type    = number
  default = 3
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D4ds_v5"
}

variable "aks_subnet_id" {
  type    = string
  default = null
}

variable "environment" {
  type    = string
  default = "production"
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
