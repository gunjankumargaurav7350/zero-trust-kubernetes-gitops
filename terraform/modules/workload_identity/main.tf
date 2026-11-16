resource "azurerm_user_assigned_identity" "identity" {
  for_each            = var.identities
  name                = each.key
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = each.value.tags
}

resource "azurerm_federated_identity_credential" "credential" {
  for_each            = var.identities
  name                = "fed-cred-${each.key}"
  resource_group_name = var.resource_group_name
  audience            = each.value.audience
  issuer              = var.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.identity[each.key].id
  subject             = each.value.subject
}

