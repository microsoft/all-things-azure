/*
 * Creates a proximity placement group for the AKS cluster.
 * 
 * @resource [azurerm_proximity_placement_group] dev
 * @param {string} name - The name of the proximity placement group.
 * @param {string} location - The location of the proximity placement group.
 * @param {string} resource_group_name - The name of the resource group where the proximity placement group will be created.
 */
resource "azurerm_proximity_placement_group" "dev" {
  name                = "proximity-group-${var.cluster_name}"
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
}