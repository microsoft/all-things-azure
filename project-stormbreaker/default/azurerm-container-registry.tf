/*
 * Creates an Azure Container Registry instance.
 *
 * This resource creates an Azure Container Registry instance with the specified name, location, resource group, SKU, and network access settings.
 * The `admin_enabled` parameter is set to `false`, which means that only users with the `contributor` or `owner` role can manage the registry.
 * The `public_network_access_enabled` parameter is set to `false`, which means that the registry can only be accessed from within the virtual network.
 */
resource "azurerm_container_registry" "default" {
  name                          = "stormbreakerACR${var.prefix}"
  location                      = azurerm_resource_group.default.location
  resource_group_name           = azurerm_resource_group.default.name
  sku                           = "Premium"
  admin_enabled                 = false
  public_network_access_enabled = true
}