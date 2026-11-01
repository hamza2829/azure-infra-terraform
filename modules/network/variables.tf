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

variable "management_ssh_cidr" {
  description = "Single permitted management SSH source."
  type        = string
}
