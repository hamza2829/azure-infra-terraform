module "resource_group" {
  source   = "./modules/resource-group"
  name     = local.names.resource_group
  location = local.location
  tags     = local.tags
}

module "network" {
  source              = "./modules/network"
  name                = local.names.network
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  management_ssh_cidr = var.management_ssh_cidr
  tags                = local.tags
}

module "monitoring" {
  source              = "./modules/monitoring"
  name                = local.names.logs
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = local.tags
}

module "storage" {
  source                     = "./modules/storage"
  name                       = local.names.storage
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  private_endpoint_subnet_id = module.network.subnet_ids["endpoints"]
  virtual_network_id         = module.network.id
  log_analytics_workspace_id = module.monitoring.id
  tags                       = local.tags
}

module "compute" {
  source                     = "./modules/compute"
  name                       = local.names.vm
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  subnet_id                  = module.network.subnet_ids["workload"]
  ssh_public_key             = var.ssh_public_key
  log_analytics_workspace_id = module.monitoring.id
  tags                       = local.tags

  # The agent needs the workload's explicit egress path in place first.
  depends_on = [module.network]
}
