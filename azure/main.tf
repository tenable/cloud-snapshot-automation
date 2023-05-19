terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.52.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

locals {
  base_tags = {
    "CreatedBy": "TenableSnapshotAutomation"
  }
  all_tags = merge(local.base_tags, var.resource_tags)
}

resource "azurerm_resource_group" "rg" {
  name = var.resource_group_name
  location = var.resource_group_location

  tags = local.all_tags
}

module "automation_account" {
  source = "./modules/automation_account"

  resource_group_name = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location

  locations = var.locations
  vm_tag = var.target_tag

  resource_tags = local.all_tags

  depends_on = [
    azurerm_resource_group.rg
  ]
}

module "runbook" {
  source = "./modules/runbook"

  automation_account_name = module.automation_account.automation_account_name
  automation_account_schedule_name = module.automation_account.job_schedule
  resource_group_name = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location

  resource_tags = local.all_tags

  depends_on = [
    module.automation_account
  ]
}

module "automation_account_iam" {
  source = "./modules/iam"

  automation_account_identity = module.automation_account.automation_account_principal_id
  subscription_id = var.subscription_id

  resource_tags = local.all_tags

  depends_on = [
    module.automation_account
  ]
}