variable "target_tag" {
  type = string
  description = "The tag attached to instances that will have snapshots automatically created. Example: \"agentless_assessment:true\""
}

variable "locations" {
  type = list(string)
  description = "Azure locations where resources will be deployed"
}

variable "subscription_id" {
  type = string
  description = "Subscription where the vault will be deployed"
}

variable "resource_group_name" {
  type = string
  description = "name of the resource group where the snapshot automation will be stored"
  default = "tenable-snapshot-automation"
}

variable "resource_group_location" {
  type = string
  description = "location for the resource group"
  default = "eastus"
}

variable "resource_tags" {
  type = map(string)
  description = "Tags that will be added to each resource deployed"
  default = {}
}