variable "resource_group_name" {
  type        = string
  description = "Resource Group Name"
}

variable "location" {
  type        = string
  description = "Azure Region"
}

variable "oidc_issuer_url" {
  type        = string
  description = "OIDC Issuer URL from AKS cluster"
}

variable "identities" {
  type = map(object({
    subject  = string
    audience = optional(list(string), ["api://AzureADTokenExchange"])
    tags     = optional(map(string), {})
  }))
  description = "Map of user-assigned workload identities configured with for_each"
  default     = {}
}
