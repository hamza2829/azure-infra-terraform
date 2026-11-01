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
  description = "Guest telemetry destination."
  type        = string
}

variable "ssh_public_key" {
  description = "Operator RSA public key."
  type        = string
}

variable "subnet_id" {
  description = "Private workload subnet."
  type        = string
}
