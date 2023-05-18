output "automation_account_principal_id" {
  value = azurerm_automation_account.automation_account.identity[0].principal_id
}

output "automation_account_name" {
  value = azurerm_automation_account.automation_account.name
}

output "job_schedule" {
  value = azurerm_automation_schedule.runbook_schedule.name
}