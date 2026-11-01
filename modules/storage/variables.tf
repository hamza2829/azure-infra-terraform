variable "name" {
  description = "Resource name derived from root naming locals."
  type        = string
}

variable "resource_group_name" {
  description = "Parent resource group name."
  type        = string
}

variable "location" {
  description = "Azure region."
  type        = string
}

variable "tags" {
  description = "Common tags from root locals."
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "Diagnostic telemetry destination."
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet for the private Blob endpoint."
  type        = string
}

variable "virtual_network_id" {
  description = "VNet linked to the private DNS zone."
  type        = string
}
