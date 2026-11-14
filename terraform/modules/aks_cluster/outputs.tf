output "cluster_id" {
  description = "AKS Cluster ID"
  value       = azurerm_kubernetes_cluster.aks.id
}

output "cluster_name" {
  description = "AKS Cluster Name"
  value       = azurerm_kubernetes_cluster.aks.name
}

output "oidc_issuer_url" {
  description = "OIDC Issuer URL"
  value       = azurerm_kubernetes_cluster.aks.oidc_issuer_url
}

output "identity_principal_id" {
  description = "Cluster System-Assigned Identity Principal ID"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
