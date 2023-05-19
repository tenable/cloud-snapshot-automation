terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4"
    }
  }
}

provider "aws" {
  region = var.region
}

locals {
  main_template = "${path.root}/main.tftpl"
  base_dir = "output"
  base_tags = {
    "CreatedBy" : "TenableSnapshotAutomation"
  }
  all_tags = merge(local.base_tags, var.resource_tags)
  all_tags_str = join(",", [
    for k,v in local.all_tags:
      "${k}:${v}"
  ])
}

resource "aws_iam_role" "dlm_execution_role" {
  name = var.dlm_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "dlm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSDataLifecycleManagerServiceRole"
  ]
}

resource "local_file" "main_tf_file" {
  for_each = toset(var.regions)
  filename = "${local.base_dir}/${each.key}/main.tf"
  content = templatefile(local.main_template, {
    "region": each.key,
    "target_tag": var.target_tag,
    "dlm_lifecycle_policy_name": var.dlm_lifecycle_policy_name,
    "iam_role_arn": aws_iam_role.dlm_execution_role.arn,
    "resource_tags_string": local.all_tags_str
  })
}