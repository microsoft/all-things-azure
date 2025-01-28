/*
 * Creates an Azure Log Analytics workspace and deploys the Container Insights solution to it. 
 * 
 * The solution provides monitoring and diagnostics for containerized applications running on 
 * Azure Kubernetes Service (AKS).
 * 
 * This code creates the following resources:
 * - azurerm_log_analytics_workspace.aks: An Azure Log Analytics workspace.
 * - azurerm_log_analytics_solution.stormbreaker: The Container Insights solution deployed to the workspace.
*/

resource "azurerm_log_analytics_workspace" "aks" {
  name                = "${var.prefix}-logA-ws"
  location            = azurerm_resource_group.default.location
  resource_group_name = azurerm_resource_group.default.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_log_analytics_solution" "stormbreaker" {
  solution_name         = "ContainerInsights"
  location              = azurerm_resource_group.default.location
  resource_group_name   = azurerm_resource_group.default.name
  workspace_resource_id = azurerm_log_analytics_workspace.aks.id
  workspace_name        = azurerm_log_analytics_workspace.aks.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/ContainerInsights"
  }
}