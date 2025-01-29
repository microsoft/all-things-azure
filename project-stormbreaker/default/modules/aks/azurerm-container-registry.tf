/* 
 * Creates a private endpoint for the Azure Container Registry and assigns the AcrPull role to the user-assigned identity.
 * 
 * Inputs:
 * - var.resource_group.location: The location of the resource group.
 * - var.resource_group.name: The name of the resource group.
 * - var.acr_subnet_id: The ID of the subnet where the private endpoint will be created.
 * - var.container_registry_id: The ID of the Azure Container Registry.
 * - var.acr_private_dns_zone_ids: The IDs of the private DNS zones associated with the Azure Container Registry.
 * - var.user_assigned_identity.principal_id: The principal ID of the user-assigned identity.
 * 
 * Outputs:
 * - azurerm_private_endpoint.acr: The created private endpoint.
 * - azurerm_role_assignment.mi-access-to-acr: The role assignment for the user-assigned identity.
 * 
 */
resource "azurerm_private_endpoint" "acr" {
  name                = "${local.cluster_name}-acr-endpoint"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  subnet_id           = var.acr_subnet_id

  private_service_connection {
    name                           = "${local.cluster_name}-acr-connection"
    private_connection_resource_id = var.container_registry_id
    is_manual_connection           = false
    subresource_names              = ["registry"]
  }

  private_dns_zone_group {
    name                 = "acr-private-endpoint-group"
    private_dns_zone_ids = var.acr_private_dns_zone_ids
  }
}

resource "azurerm_role_assignment" "mi-access-to-acr" {
  scope                = var.container_registry_id
  role_definition_name = "AcrPull"
  principal_id         = var.user_assigned_identity.principal_id
}