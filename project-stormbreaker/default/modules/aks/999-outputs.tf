/* Outputs */
output "cluster_name" {
  value = azurerm_kubernetes_cluster.dev.name
}

data "azurerm_kubernetes_cluster" "stormbreaker-cluster" {
  name                = azurerm_kubernetes_cluster.dev.name
  resource_group_name = var.resource_group.name
}

output "kube_config" {
  value = data.azurerm_kubernetes_cluster.stormbreaker-cluster.kube_config_raw
}

output "oidc_url" {
  value = azurerm_kubernetes_cluster.dev.oidc_issuer_url
}