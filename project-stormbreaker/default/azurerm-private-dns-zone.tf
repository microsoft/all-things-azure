resource "azurerm_private_dns_zone" "acr" {
  name                = "privatelink.azurecr.io"
  resource_group_name = azurerm_resource_group.default.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "private-zone-link" {
  name                  = "stormbreaker-private-zone-link"
  resource_group_name = azurerm_resource_group.default.name
  private_dns_zone_name = azurerm_private_dns_zone.acr.name
  virtual_network_id    = azurerm_virtual_network.stormbreaker-vnet.id
}

resource "azurerm_role_assignment" "stormbreaker-private-dns-zone" {
  scope                = azurerm_private_dns_zone.acr.id
  role_definition_name = "Private DNS Zone Contributor"
  principal_id         = azurerm_user_assigned_identity.managed-id.principal_id
}

resource "azurerm_federated_identity_credential" "stormbreaker-external-dns-identity" {
  name                = "external-dns-identity"
  resource_group_name = azurerm_resource_group.default.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = module.aks.oidc_url
  parent_id           = azurerm_user_assigned_identity.managed-id.id
  subject             = "system:serviceaccount:default:external-dns"
}