variable "target_tag" {
  type = string
  description = "The tag attached to instances that will have snapshots automatically created. Example: \"agentless_assessment:true\""
}

variable "regions" {
  type = list(string)
  description = "Regions where the snapshot automation will be deployed"
}

variable "region" {
  type = string
  description = "Region where the initial terraform provider will run which creates the IAM role"
  default = "us-east-1"
}

variable "dlm_lifecycle_policy_name" {
  type = string
  description = "Name of the DLM policy deployed"
  default = "tenable-snapshot-policy"
}

variable "dlm_role_name" {
  type = string
  description = "Name of the DLM role deployed"
  default = "dlm-execution-role"
}

variable "resource_tags" {
  type = map(string)
  description = "Tags that will be added to each resource deployed and snapshot"
  default = {}
}