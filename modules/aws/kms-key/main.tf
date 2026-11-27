terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}

locals {
  account_root = "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
  admin_arns   = length(var.key_admin_arns) > 0 ? var.key_admin_arns : [local.account_root]
}

data "aws_iam_policy_document" "this" {
  # Keeps the key manageable through IAM in this account (prevents lock-out).
  statement {
    sid       = "EnableIAMPolicies"
    actions   = ["kms:*"]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = [local.account_root]
    }
  }

  # Administrators can manage the key but not use it to decrypt data.
  statement {
    sid = "KeyAdministration"
    actions = [
      "kms:Create*", "kms:Describe*", "kms:Enable*", "kms:List*", "kms:Put*",
      "kms:Update*", "kms:Revoke*", "kms:Disable*", "kms:Get*", "kms:Delete*",
      "kms:TagResource", "kms:UntagResource", "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion", "kms:RotateKeyOnDemand",
    ]
    resources = ["*"]
    principals {
      type        = "AWS"
      identifiers = local.admin_arns
    }
  }

  dynamic "statement" {
    for_each = length(var.key_user_arns) > 0 ? [1] : []
    content {
      sid = "KeyUsage"
      actions = [
        "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*",
        "kms:GenerateDataKey*", "kms:DescribeKey",
      ]
      resources = ["*"]
      principals {
        type        = "AWS"
        identifiers = var.key_user_arns
      }
    }
  }

  # Lets AWS services (e.g. cloudtrail.amazonaws.com, logs.<region>.amazonaws.com)
  # use the key, but only on behalf of this account.
  dynamic "statement" {
    for_each = length(var.service_principals) > 0 ? [1] : []
    content {
      sid = "AllowAWSServices"
      actions = [
        "kms:Encrypt", "kms:Decrypt", "kms:ReEncrypt*",
        "kms:GenerateDataKey*", "kms:DescribeKey",
      ]
      resources = ["*"]
      principals {
        type        = "Service"
        identifiers = var.service_principals
      }
      condition {
        test     = "StringEquals"
        variable = "aws:SourceAccount"
        values   = [data.aws_caller_identity.current.account_id]
      }
    }
  }
}

resource "aws_kms_key" "this" {
  description             = var.description
  enable_key_rotation     = true
  rotation_period_in_days = var.rotation_period_in_days
  deletion_window_in_days = var.deletion_window_in_days
  multi_region            = var.multi_region
  policy                  = data.aws_iam_policy_document.this.json
  tags                    = var.tags
}

resource "aws_kms_alias" "this" {
  name          = "alias/${var.alias}"
  target_key_id = aws_kms_key.this.key_id
}
