terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

# CIS 1.8-1.9: strong IAM password policy.
resource "aws_iam_account_password_policy" "this" {
  minimum_password_length        = var.minimum_password_length
  require_lowercase_characters   = true
  require_uppercase_characters   = true
  require_numbers                = true
  require_symbols                = true
  allow_users_to_change_password = true
  password_reuse_prevention      = 24
  max_password_age               = var.max_password_age
  hard_expiry                    = false
}

# Account-wide S3 Block Public Access (CIS 2.1.4).
resource "aws_s3_account_public_access_block" "this" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Encrypt every new EBS volume in this Region (CIS 2.2.1).
resource "aws_ebs_encryption_by_default" "this" {
  enabled = true
}

resource "aws_ebs_default_kms_key" "this" {
  count   = var.ebs_kms_key_arn == null ? 0 : 1
  key_arn = var.ebs_kms_key_arn
}

# Finds resources shared outside the account (CIS 1.20).
resource "aws_accessanalyzer_analyzer" "this" {
  count         = var.enable_access_analyzer ? 1 : 0
  analyzer_name = var.access_analyzer_name
  type          = var.access_analyzer_type
  tags          = var.tags
}

# Turns on Security Hub with the AWS Foundational and CIS standards.
resource "aws_securityhub_account" "this" {
  count                    = var.enable_security_hub ? 1 : 0
  enable_default_standards = false
  auto_enable_controls     = true
}

data "aws_partition" "current" {}
data "aws_region" "current" {}

locals {
  security_hub_standards = var.enable_security_hub ? {
    fsbp = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standards/aws-foundational-security-best-practices/v/1.0.0"
    cis  = "arn:${data.aws_partition.current.partition}:securityhub:${data.aws_region.current.name}::standards/cis-aws-foundations-benchmark/v/3.0.0"
  } : {}
}

resource "aws_securityhub_standards_subscription" "this" {
  for_each      = local.security_hub_standards
  standards_arn = each.value
  depends_on    = [aws_securityhub_account.this]
}
