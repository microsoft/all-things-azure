/*
 * This file contains the definition of input variables for the Refinitiv on Azure pattern. 
 * These variables can be used to customize the deployment of the pattern to suit your needs.
 * 
 * The variables defined in this file are:
 * - prefix: a string value to prefix resource names with.
 * - suffix: a string value to suffix resource names with.
 * - location: a string value representing the default Azure region.
 * - custom_domain: a string value representing the custom domain to use.
 * - admin_username: a string value representing the admin username.
 * - admin_password: a string value representing the admin password.
 * - aks_admin_group_object_ids: a list of Azure Active Directory object IDs for the AKS admin group.
 * - acr_subnet_id: a string value representing the ID of the subnet where the ACR is deployed.
 * - acr_private_dns_zone_ids: a list of private DNS zone IDs for the ACR.
 */
variable "prefix" {
  type        = string
  description = "Value to prefix resource names with."
  default     = "demo"
}

variable "suffix" {
  type        = string
  description = "Value to suffix resource names with."
  default     = "gbb"
}

variable "location" {
  type        = string
  description = "Default Azure Region"
  default     = "westus3"
}

variable "custom_domain" {
  type    = string
  default = "azuregbb.com"
}

variable "admin_username" {
  type    = string
  default = "gbbadmin"
}

variable "admin_password" {
  type    = string
  default = ""
}

variable "aks_admin_group_object_ids" {
  type    = list(any)
  default = []
}

variable "acr_subnet_id" {
  type    = string
  default = ""
}