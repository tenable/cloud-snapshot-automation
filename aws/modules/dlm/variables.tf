variable "target_tag" {
  type = string
  description = "The tag associated with the VMs that will have snapshots automatically created. Example: \"agentless_assessment:true\""
}

variable "dlm_lifecycle_policy_name" {
  type = string
  description = ""
}

variable "iam_role_arn" {
  type = string
}

variable "resource_tags_string" {
  type = string
}