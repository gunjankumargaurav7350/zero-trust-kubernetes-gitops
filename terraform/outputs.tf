output "aks_cluster_name" {
  description = "Name of the Zero-Trust AKS cluster"
  value       = azurerm_kubernetes_cluster.zero_trust_aks.name
}

output "aks_oidc_issuer_url" {
  description = "OIDC Issuer URL for Workload Identity service accounts"
  value       = azurerm_kubernetes_cluster.zero_trust_aks.oidc_issuer_url
}

output "workload_identity_client_id" {
  description = "Client ID of the User Assigned Identity for K8s pod authentication"
  value       = azurerm_user_assigned_identity.workload_app_id.client_id
}
