/* 
 * Module variables for the AKS module.
 * 
 * Variables:
 * - prefix: The prefix to use for all resources created by this module.
 * - suffix: The suffix to use for all resources created by this module.
 * - cluster_name: The name of the AKS cluster.
 * - uid: The unique identifier for the AKS cluster.
 * - subnet_id: The ID of the subnet where the AKS cluster will be deployed.
 * - acr_subnet_id: The ID of the subnet where the ACR instance is deployed.
 * - acr_private_dns_zone_ids: The IDs of the private DNS zones associated with the ACR instance.
 * - resource_group: The resource group where the AKS cluster will be deployed.
 * - aks_settings: The settings for the AKS cluster.
 * - default_node_pool: The settings for the default node pool.
 * - user_node_pools: The settings for the user-defined node pools.
 */ 
variable "prefix" {
  type = string
}

variable "suffix" {
  type = string
}

variable "cluster_name" {
  type    = string
  default = ""
}

variable "uid" {
  type    = string
  default = ""
}

variable "subnet_id" {
  type = string
}

variable "acr_subnet_id" {
  type = string
}

variable "acr_private_dns_zone_ids" {
  type = list(any)
}

variable "resource_group" {
}

variable "aks_settings" {
  type = object({
    kubernetes_version      = string
    private_cluster_enabled = bool
    identity                = string
    outbound_type           = string
    network_plugin          = string
    network_plugin_mode     = string
    network_policy          = string
    load_balancer_sku       = string
    service_cidr            = string
    dns_service_ip          = string
    admin_username          = string
    ssh_key                 = string
    blob_driver_enabled     = bool
    keda_enabled            = bool
  
  })
  default = {
    kubernetes_version      = null
    private_cluster_enabled = false
    identity                = "SystemAssigned"
    outbound_type           = "loadBalancer"
    network_plugin          = "azure"
    network_plugin_mode     = "overlay"
    network_policy          = "calico"
    load_balancer_sku       = "standard"
    service_cidr            = "10.174.128.0/17"
    dns_service_ip          = "10.174.128.10"
    admin_username          = "azureuser"
    ssh_key                 = null
    blob_driver_enabled     = false
    keda_enabled            = false
  }
}

variable "default_node_pool" {
  type = object({
    name                = string
    enable_auto_scaling = bool
    node_count          = number
    min_count           = number
    max_count           = number
    vm_size             = string
    type                = string
    os_disk_size_gb     = number
    proximity_placement_group_id = string
  })

  default = {
    name                = "defaultnp"
    enable_auto_scaling = true
    node_count          = 2
    min_count           = 2
    max_count           = 5
    vm_size             = "Standard_D4s_v3"
    type                = "VirtualMachineScaleSets"
    os_disk_size_gb     = 30
    proximity_placement_group_id = null
  }
}

variable "user_node_pools" {
  type = map(object({
    vm_size     = string
    node_count  = number
    node_labels = map(string)
    node_taints = list(string)
    zones       = list(string)
    proximity_placement_group_id = string
    ultra_ssd_enabled = bool
  }))

  default = {
    "usernp1" = {
      vm_size     = "Standard_D4s_v3"
      node_count  = 3
      node_labels = null
      node_taints = []
      zones       = [3]
      proximity_placement_group_id = null
      ultra_ssd_enabled = false
    }
  }
}

variable "admin_username" {
  type    = string
  default = "gbbadmin"
}

variable "aks_admin_group_object_ids" {
  type    = list(any)
  default = []
}

variable "user_assigned_identity" {
}

variable "log_analytics_workspace" {
}

variable "container_registry_id" {
}