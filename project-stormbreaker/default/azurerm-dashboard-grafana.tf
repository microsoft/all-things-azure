/* 
 * Creates a Grafana dashboard in Azure with the specified name and settings.
 * 
 * This resource block creates a Grafana dashboard in Azure with the specified name and settings.
 * The dashboard is created in the specified resource group and location.
 * 
 * @required resource_group_name The name of the resource group in which to create the dashboard.
 * @required location The location in which to create the dashboard.
 * @optional api_key_enabled Whether to enable API key authentication for the dashboard.
 * @optional deterministic_outbound_ip_enabled Whether to enable deterministic outbound IP addresses for the dashboard.
 * @optional public_network_access_enabled Whether to enable public network access for the dashboard.
 * @optional identity.type The type of identity to assign to the dashboard. Defaults to "SystemAssigned".
 * @optional tags A mapping of tags to assign to the dashboard.
 */
resource "azurerm_dashboard_grafana" "stormbreaker-grafana" {
  name                              = "stormbreaker-grafana${var.suffix}"
  resource_group_name               = azurerm_resource_group.default.name
  location                          = azurerm_resource_group.default.location
  api_key_enabled                   = true
  deterministic_outbound_ip_enabled = true
  public_network_access_enabled     = true

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "stormbreaker Demo"
  }
}