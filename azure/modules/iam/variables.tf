variable "subscription_id" {
  type = string
  description = "Subscription where the IAM role will have scope over"
}

variable "automation_account_identity" {
  type = string
  description = "The principal id of the system assigned identity for the automation account"
}

variable "resource_tags" {
  type = map(string)
}