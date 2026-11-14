output "aks_clusters" {
  description = "AKS clusters provisioned via modular for_each"
  value = {
    for k, v in module.aks_clusters : k => {
      id                   = v.cluster_id
      name                 = v.cluster_name
      oidc_issuer_url      = v.oidc_issuer_url
      identity_principal_id = v.identity_principal_id
    }
  }
}

output "workload_identities" {
  description = "Workload identities and federated credentials created via modular for_each"
  value       = module.workload_identity.identities
}
