locals {
  target_key    = split(":", var.target_tag)[0]
  target_value  = split(":", var.target_tag)[1]

  resource_tags = {
   for tag in split(",", var.resource_tags_string):
      split(":", tag)[0] => split(":", tag)[1]
  }
}

resource "aws_dlm_lifecycle_policy" "dlm_policy" {
  description        = "DLM policy for daily snapshot creation for VM scanning purposes"
  state              = "ENABLED"
  execution_role_arn = var.iam_role_arn

  policy_details {
    resource_types = ["INSTANCE"]

    target_tags = {
      (local.target_key) = local.target_value
    }

    schedule {
      name        = "Daily Snapshots"
      tags_to_add = local.resource_tags
      create_rule {
        interval      = 24
        interval_unit = "HOURS"
        times         = ["04:00"]
      }
      retain_rule {
        count = 1
      }
      copy_tags = true
    }
  }

  tags = merge({
    Name = var.dlm_lifecycle_policy_name
  }, local.resource_tags)
}