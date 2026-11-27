terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

provider "aws" {
  region = var.region

  default_tags {
    tags = {
      ManagedBy = "terraform"
      Purpose   = "security-baseline"
    }
  }
}

data "aws_caller_identity" "current" {}

locals {
  suffix = "${data.aws_caller_identity.current.account_id}-${var.region}"
}

# 1. Customer managed key for security logs.
module "logs_key" {
  source             = "../../modules/aws/kms-key"
  alias              = "security-logs"
  description        = "Encrypts CloudTrail logs"
  service_principals = ["cloudtrail.amazonaws.com"]
}

# 2. Multi-Region CloudTrail into a hardened, KMS-encrypted bucket.
module "cloudtrail" {
  source      = "../../modules/aws/cloudtrail"
  name        = "security-trail"
  bucket_name = "security-cloudtrail-${local.suffix}"
  kms_key_arn = module.logs_key.key_arn
}

# 3. Threat detection with high-severity email alerts.
module "guardduty" {
  source       = "../../modules/aws/guardduty"
  alert_emails = var.alert_emails
}

# 4. Account guardrails: password policy, S3 BPA, EBS encryption,
#    Access Analyzer and Security Hub.
module "account_baseline" {
  source = "../../modules/aws/account-baseline"
}

# 5. Flow logs for an existing VPC (optional).
module "vpc_flow_logs" {
  count  = var.vpc_id == null ? 0 : 1
  source = "../../modules/aws/vpc-flow-logs"
  vpc_id = var.vpc_id
}
