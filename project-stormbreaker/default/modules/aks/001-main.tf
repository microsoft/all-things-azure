resource "random_integer" "uid" {
  min = 0
  max = 99
}

locals {
  prefix    = var.prefix
  suffix    = var.suffix
  workspace = terraform.workspace
  uid       = var.uid != "" ? var.uid : random_integer.uid.result

  cluster_name = var.cluster_name != "" ? var.cluster_name : "${local.prefix}${local.workspace}${local.suffix}${local.uid}"
}