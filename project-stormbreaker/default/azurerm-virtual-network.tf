# VNet Definition
resource "azurerm_virtual_network" "stormbreaker-vnet" {
  name                = "stormbreaker-vnet"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  address_space       = ["10.255.0.0/16"]
}

# Subnets
resource "azurerm_subnet" "stormbreaker-cluster" {
  name                                      = "snet-aks-stormbreaker-cluster"
  resource_group_name                       = azurerm_resource_group.default.name
  virtual_network_name                      = azurerm_virtual_network.stormbreaker-vnet.name
  private_endpoint_network_policies_enabled = false
  address_prefixes                          = ["10.255.1.0/24"]
  service_endpoints                         = ["Microsoft.Storage"]
}

resource "azurerm_subnet" "acr" {
  name                                      = "AcrSubnet"
  resource_group_name                       = azurerm_resource_group.default.name
  virtual_network_name                      = azurerm_virtual_network.stormbreaker-vnet.name
  private_endpoint_network_policies_enabled = false
  address_prefixes                          = ["10.255.2.0/24"]
}

