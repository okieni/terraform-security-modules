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
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  trail_arn  = "arn:${data.aws_partition.current.partition}:cloudtrail:${data.aws_region.current.name}:${local.account_id}:trail/${var.name}"
  bucket_arn = "arn:${data.aws_partition.current.partition}:s3:::${var.bucket_name}"
}

# Bucket policy statements CloudTrail needs to deliver logs, scoped to this trail.
data "aws_iam_policy_document" "cloudtrail_delivery" {
  statement {
    sid       = "AWSCloudTrailAclCheck"
    actions   = ["s3:GetBucketAcl"]
    resources = [local.bucket_arn]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }

  statement {
    sid       = "AWSCloudTrailWrite"
    actions   = ["s3:PutObject"]
    resources = ["${local.bucket_arn}/AWSLogs/${local.account_id}/*"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [local.trail_arn]
    }
  }
}

# Log bucket built from the hardened S3 module in this repo.
module "log_bucket" {
  source = "../s3-secure-bucket"

  bucket_name                        = var.bucket_name
  kms_key_arn                        = var.kms_key_arn
  access_log_bucket                  = var.access_log_bucket
  noncurrent_version_expiration_days = 365
  additional_policy_json             = [data.aws_iam_policy_document.cloudtrail_delivery.json]
  force_destroy                      = var.force_destroy
  tags                               = var.tags
}

# Optional CloudWatch Logs delivery (needed for metric filters / alarms).
resource "aws_cloudwatch_log_group" "this" {
  count             = var.enable_cloudwatch_logs ? 1 : 0
  name              = "/aws/cloudtrail/${var.name}"
  retention_in_days = var.cloudwatch_retention_days
  tags              = var.tags
}

data "aws_iam_policy_document" "assume_cloudtrail" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["cloudtrail.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "cloudwatch" {
  count              = var.enable_cloudwatch_logs ? 1 : 0
  name               = "${var.name}-cloudtrail-to-cloudwatch"
  assume_role_policy = data.aws_iam_policy_document.assume_cloudtrail.json
  tags               = var.tags
}

resource "aws_iam_role_policy" "cloudwatch" {
  count = var.enable_cloudwatch_logs ? 1 : 0
  name  = "write-cloudtrail-logs"
  role  = aws_iam_role.cloudwatch[0].id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect   = "Allow"
      Action   = ["logs:CreateLogStream", "logs:PutLogEvents"]
      Resource = "${aws_cloudwatch_log_group.this[0].arn}:*"
    }]
  })
}

resource "aws_cloudtrail" "this" {
  name                          = var.name
  s3_bucket_name                = module.log_bucket.bucket_id
  is_multi_region_trail         = true
  include_global_service_events = true
  enable_log_file_validation    = true
  is_organization_trail         = var.is_organization_trail
  kms_key_id                    = var.kms_key_arn

  cloud_watch_logs_group_arn = var.enable_cloudwatch_logs ? "${aws_cloudwatch_log_group.this[0].arn}:*" : null
  cloud_watch_logs_role_arn  = var.enable_cloudwatch_logs ? aws_iam_role.cloudwatch[0].arn : null

  dynamic "event_selector" {
    for_each = var.log_s3_data_events ? [1] : []
    content {
      read_write_type           = "All"
      include_management_events = true
      data_resource {
        type   = "AWS::S3::Object"
        values = ["arn:${data.aws_partition.current.partition}:s3"]
      }
    }
  }

  tags = var.tags

  depends_on = [module.log_bucket, aws_iam_role_policy.cloudwatch]
}
