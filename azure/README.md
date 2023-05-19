## Microsoft Azure
Automating Azure snapshots is achieved through the use of a Powershell Azure Runbook. The Terraform template provided
deploys the following resources.

#### Resource Group
A Resource Group is created in the subscription for the Automation Account and Runbook

#### Automation Account
An Automation Account with a Managed Identity is created to automate the execution of the runbook on a 24-hour schedule,
store the `target_tag`, `resource_tags`, and `locations` values provided during deployment, and provide the runbook with
the permissions needed to discover VMs and snapshot them.

#### Runbook
The Powershell Runbook authenticates as the Automation Account Managed Identity and queries for VMs with the `target_tag`
in the `locations` provided. It then generates a new incremental snapshot of the VM's OS Disk. If one has previously
been generated then it will be updated.

#### IAM Role
A custom role is created and assigned to the Automation Account Managed Identity with the minimal
amount of privilege required. This is a global resource and does not reside in the resource group.
```json
[
  "Microsoft.Compute/virtualMachines/read",
  "Microsoft.ClassicCompute/virtualMachines/read",
  "Microsoft.Compute/snapshots/write",
  "Microsoft.Compute/snapshots/read"
]
```

### Preparation
* Identify the Azure locations where snapshots should be generated
* Determine the tag to use for targeting VMs to snapshot
* Identify the Azure subscription to deploy the automation

#### Mandatory Variables
* `target_tag`: The tag the [runbook](modules/runbook/snapshot_automation.ps1) will use to filter VMs
    * Example: `-var='target_tag=agentless_assessment:true'`
* `locations`: The list of Azure locations where the [runbook](modules/runbook/snapshot_automation.ps1) will look
  for VMs with the target tag applied
    * Example: `-var='locations=["eastus","eastus2","northcentralus","westus"]'`
* `subscription_id`: The subscription where the Azure Terraform provider will deploy resources
    * Example: `-var='subscription_id=85ada38f-328e-48db-ae1d-1b702c6954ff'`

#### Optional Variables
* `resource_group_name` (default: tenable-snapshot-automation) : Define your own resource group name where the
  automation account and runbook will reside
* `resource_group_location` (default: eastus) : Define the resource group location somewhere other than eastus
* `resource_tags` (default: {}): Any tags you would like to add on to the resources deployed by terraform and snapshots 
created by the runbook

#### Example Terraform Apply
```bash
cd ./azure

terraform init

terraform apply \
  -var='locations=["eastus","eastus2","northcentralus","westus"]' \
  -var='target_tag=agentless_assessment:true' \
  -var='subscription_id=85ada38f-328e-48db-ae1d-1b702c6954ff'
`````