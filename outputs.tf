output "resource_group_name" {
  description = "Proposed resource group name. Outputs do not indicate an actual deployment."
  value       = module.resource_group.name
}

output "virtual_network_id" {
  description = "Virtual network resource ID after a future deployment."
  value       = module.network.id
}

output "subnet_ids" {
  description = "Subnet IDs keyed by workload, management, and endpoints."
  value       = module.network.subnet_ids
}

output "storage_account_name" {
  description = "Storage account name; global availability has not been tested."
  value       = module.storage.name
}

output "log_analytics_workspace_id" {
  description = "Destination for configured telemetry."
  value       = module.monitoring.id
}

output "vm_private_ip" {
  description = "VM private address after a future deployment; the VM has no public IP."
  value       = module.compute.private_ip
}

output "vm_principal_id" {
  description = "System-assigned VM identity. No storage data access is granted."
  value       = module.compute.principal_id
}
