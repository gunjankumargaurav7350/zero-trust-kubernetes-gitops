# -------------------------------------------------------------------------------------------------
# Entra ID Workload Identity: Passwordless Pod Authentication
# -------------------------------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "workload_app_id" {
  name                = "uai-k8s-payment-prod"
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = azurerm_resource_group.aks_rg.location
  tags                = var.tags
}

resource "azurerm_federated_identity_credential" "k8s_fed_cred" {
  name                = "fed-cred-payment-service"
  resource_group_name = azurerm_resource_group.aks_rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.zero_trust_aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.workload_app_id.id
  subject             = "system:serviceaccount:payments:payment-service-sa"
}
