/* Create a resource group */
resource "azurerm_resource_group" "default" {
  name     = "rg-${var.prefix}-${var.suffix}"
  location = var.location
}