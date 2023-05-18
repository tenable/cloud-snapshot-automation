data "local_file" "runbook_script" {
  filename = "${path.module}/snapshot_automation.ps1"
}

resource "azurerm_automation_runbook" "snapshot_automation" {
  name                    = "tenable-snapshot-automation"

  resource_group_name     = var.resource_group_name
  location                = var.resource_group_location
  automation_account_name = var.automation_account_name
  log_verbose             = "false"
  log_progress            = "false"
  runbook_type            = "PowerShell"

  job_schedule {
    schedule_name = var.automation_account_schedule_name
  }
  content = data.local_file.runbook_script.content

  tags = var.resource_tags
}