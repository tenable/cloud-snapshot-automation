variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "resource_tags" {
  type = map(string)
}

variable "locations" {
  type = list(string)
  description = "Azure locations where resources will be deployed"
}

variable "vm_tag" {
  type = string
  description = "The tag associated with the VMs that will be automatically added to Azure Backup Vault. Ex: \"tenable:agentless\""
}

variable "automation_account_name" {
  type = string
  default = "tenable-snapshot-automation"
  description = "Name of the automation account deployed"
}