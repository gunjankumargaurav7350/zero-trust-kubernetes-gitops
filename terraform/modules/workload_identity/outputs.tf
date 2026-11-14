output "identities" {
  description = "Map of created workload identities and credentials"
  value = {
    for k, v in azurerm_user_assigned_identity.identity : k => {
      id           = v.id
      client_id    = v.client_id
      principal_id = v.principal_id
    }
  }
}
