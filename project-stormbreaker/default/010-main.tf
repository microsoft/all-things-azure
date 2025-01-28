/*
 * This block of code sets up the required providers for the Terraform configuration, 
 * including the azurerm provider and the azapi provider. It also configures the azurerm provider 
 * to enable certain features, such as preventing deletion of resource groups that contain 
 * resources and rolling instances when required. Additionally, it defines several resources, 
 * including a random string suffix, a random password for a certificate, and a local variable 
 * for the zone name.
 */ 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.88.0"
    }
    azapi = {
      source  = "azure/azapi"
      version = ">=1.5.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
     prevent_deletion_if_contains_resources = false
    }
    }
}

data "azurerm_subscription" "current" {
}

data "azurerm_client_config" "current" {}

data "http" "myip" {
  url = "https://api.ipify.org/"
}

resource "random_string" "suffix" {
  length  = 4
  special = false
  upper   = false
  lower   = true
  numeric = false
}

resource "random_password" "cert_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

locals {
  prefix        = var.prefix
  suffix        = var.suffix
  cert_password = random_password.cert_password.result
  zone_name     = "${var.location}.${var.custom_domain}"
}