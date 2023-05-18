variable "resource_group_name" {
  type = string
}

variable "resource_group_location" {
  type = string
}

variable "automation_account_name" {
  type = string
}

variable "automation_account_schedule_name" {
  type = string
}

variable "resource_tags" {
  type = map(string)
}