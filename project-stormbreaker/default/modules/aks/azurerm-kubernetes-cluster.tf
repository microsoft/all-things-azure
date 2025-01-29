/* 
 * This Terraform module creates an AKS (Azure Kubernetes Service) cluster in Azure. 
 * It creates a Kubernetes cluster with a default node pool and optionally creates additional 
 * user node pools. It also configures various settings for the cluster, such as network and 
 * identity settings. This module requires the AzureRM provider and the Kubernetes provider to be configured.
 */

# data "azurerm_user_assigned_identity" "managed-id" {
#   name                = "aks-user-assigned-managed-id"
#   resource_group_name = var.resource_group.name
# }

resource "azurerm_kubernetes_cluster" "dev" {
  name                = var.cluster_name == true ? var.cluster_name : local.cluster_name
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name

  dns_prefix = local.cluster_name

  kubernetes_version      = var.aks_settings.kubernetes_version
  private_cluster_enabled = var.aks_settings.private_cluster_enabled

  /* workload id */
  workload_identity_enabled = true
  oidc_issuer_enabled       = true

  /* prometheus */
  monitor_metrics {}

  default_node_pool {
    name                = var.default_node_pool.name
    enable_auto_scaling = var.default_node_pool.enable_auto_scaling
    min_count           = var.default_node_pool.min_count
    max_count           = var.default_node_pool.max_count
    vm_size             = var.default_node_pool.vm_size
    os_disk_size_gb     = var.default_node_pool.os_disk_size_gb
    type                = var.default_node_pool.type
    vnet_subnet_id      = var.subnet_id
    proximity_placement_group_id = var.default_node_pool.proximity_placement_group_id
  }

  identity {
    type = var.aks_settings.identity
    identity_ids = [
      var.user_assigned_identity.id
    ]
  }

  linux_profile {
    admin_username = var.aks_settings.admin_username
    ssh_key {
      key_data = file(var.aks_settings.ssh_key)
    }
  }

  network_profile {
    network_plugin    = var.aks_settings.network_plugin
    network_plugin_mode = var.aks_settings.network_plugin_mode
    network_policy    = var.aks_settings.network_policy
    load_balancer_sku = var.aks_settings.load_balancer_sku
    service_cidr      = var.aks_settings.service_cidr
    dns_service_ip    = var.aks_settings.dns_service_ip
    outbound_type     = var.aks_settings.private_cluster_enabled == true ? "userDefinedRouting" : "loadBalancer"
  }

  storage_profile {
    blob_driver_enabled = var.aks_settings.blob_driver_enabled
  }

  workload_autoscaler_profile {
    keda_enabled        = var.aks_settings.keda_enabled
  }
  
  oms_agent {
    log_analytics_workspace_id = var.log_analytics_workspace
    msi_auth_for_monitoring_enabled = true
  }

  # For certain services/features; requires more API request limits to CP/ARM
  sku_tier = "Standard"

  # role_based_access_control_enabled = false

  # azure_active_directory_role_based_access_control {
  #   managed = true
  #   azure_rbac_enabled = true
  #   admin_group_object_ids = var.aks_admin_group_object_ids
  # }

  lifecycle {
    ignore_changes = [
      # In case the cluster is upgraded via an out-of-band process (i.e. Portal or AzCLI)
      kubernetes_version
    ]
  }

}

resource "azurerm_kubernetes_cluster_node_pool" "user" {
  for_each = var.user_node_pools

  name                  = each.key
  kubernetes_cluster_id = azurerm_kubernetes_cluster.dev.id
  vm_size               = each.value.vm_size
  node_count            = each.value.node_count
  mode                  = "User"
  node_labels           = each.value.node_labels
  vnet_subnet_id        = var.subnet_id
  node_taints           = each.value.node_taints
  proximity_placement_group_id = each.value.proximity_placement_group_id
  ultra_ssd_enabled     = each.value.ultra_ssd_enabled
  zones                 = each.value.zones
}
