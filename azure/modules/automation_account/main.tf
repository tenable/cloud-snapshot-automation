resource "azurerm_automation_account" "automation_account" {
  name                = var.automation_account_name
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku_name = "Basic"
  public_network_access_enabled = false

  identity {
    type = "SystemAssigned"
  }

  tags = var.resource_tags
}

resource "azurerm_automation_variable_string" "env_tag" {
  name                    = "TAG"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account.name
  value                   = var.vm_tag
}

resource "azurerm_automation_variable_string" "env_locations" {
  name                    = "LOCATIONS"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account.name
  value                   = join(",", [for s in var.locations : format("%q", s)])
}

resource "azurerm_automation_variable_string" "env_resource_tags" {
  name                    = "RESOURCE_TAGS"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account.name
  value                   = jsonencode(var.resource_tags)
}

resource "azurerm_automation_schedule" "runbook_schedule" {
  name                    = "tenable-snapshot-sched"
  resource_group_name     = var.resource_group_name
  automation_account_name = azurerm_automation_account.automation_account.name
  frequency               = "Hour"
  interval                = 24
  description             = "Snapshot Automation Schedule"
}
