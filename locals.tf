locals {
  location = "westeurope"
  prefix   = "${var.project}-${var.env}-weu-${var.instance}"

  tags = {
    env           = var.env
    owner         = trimspace(var.owner)
    "cost-center" = trimspace(var.cost_center)
    project       = var.project
    "managed-by"  = "terraform"
  }

  names = {
    resource_group = "rg-${local.prefix}"
    network        = "vnet-${local.prefix}"
    storage        = "st${var.project}${var.env}${var.instance}${var.unique_suffix}"
    logs           = "log-${local.prefix}"
    vm             = "vm-${local.prefix}"
  }
}
