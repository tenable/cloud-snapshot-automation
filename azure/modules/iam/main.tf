data "azurerm_subscription" "subscription" {
  subscription_id = var.subscription_id
}

resource "azurerm_role_assignment" "role_assignment" {
  name = random_uuid.role_assignment.result
  principal_id = var.automation_account_identity
  scope        = data.azurerm_subscription.subscription.id
  role_definition_id = azurerm_role_definition.role_def.role_definition_resource_id
}

resource "azurerm_role_definition" "role_def" {
  name  = "Tenable Snapshot Automation"
  scope = data.azurerm_subscription.subscription.id
  description = "Created to grant the Tenable Snapshot Automation runbook managed identity permission to find and snapshot VMs"

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.ClassicCompute/virtualMachines/read",
      "Microsoft.Compute/snapshots/write",
      "Microsoft.Compute/snapshots/read"
    ]
  }
  assignable_scopes = [
    data.azurerm_subscription.subscription.id
  ]
}

resource "random_uuid" "role_assignment" {}