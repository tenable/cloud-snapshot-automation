## Amazon Web Services (AWS)
AWS provides the [Data Lifecycle Manager](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/snapshot-lifecycle.html)
(DLM) to automatically snapshotting EC2 instances by tag. The Terraform template provided assists in deployment
of a DLM policy to each region you provide in the `regions` variable. It achieves this by generating individual 
terraform templates for each of the `regions` using a [template](main.tftpl) to the `output` directory.

```
output
├── us-east-1
│ └── main.tf
└── us-east-2
  └── main.tf
```

Each template can then be deployed individually or by using the [deploy-all.sh](deploy-all.sh) bash script provided. 
Another utility script has been provided to assist with destroying each of deployed resources [here](destroy-all.sh).

### Preparation
* Identify the AWS regions where snapshots should be generated
* Identify the tag to use to targeting which AWS EC2 instances to snapshot

#### Mandatory Variables
* `target_tag`: The tag the DLM policy target EC2 instances
  * Example: `-var='target_tag=agentless_assessment:true'`
* `regions`: The list of AWS Regions the Terraform template will generate new templates for
  * Example: `-var='regions=["us-east-1","us-east-2"]'`

#### Optional Variables
* `region` (default: us-east-1): The region the main terraform template will use to create the IAM role
* `dlm_lifecycle_policy_name` (default: tenable-snapshot-policy): If you would prefer the policy be named something else
* `dlm_role_name` (default: dlm-execution-role): The name of the IAM role deployed 
* `resource_tags` (default: {}): Any tags you would like to add on to the resources deployed by terraform

### Example Terraform Apply
```bash
cd ./aws

terraform init

terraform apply \
  -var='regions=["us-east-1","us-east-2"]' \
  -var='target_tag=agentless_assessment:true'  
  
./deploy-all
`````