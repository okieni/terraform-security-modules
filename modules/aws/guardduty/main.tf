terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.50"
    }
  }
}

resource "aws_guardduty_detector" "this" {
  enable                       = true
  finding_publishing_frequency = var.finding_publishing_frequency
  tags                         = var.tags
}

# Extra protection plans (S3, EKS, malware scanning, RDS, Lambda, runtime).
resource "aws_guardduty_detector_feature" "this" {
  for_each    = toset(var.features)
  detector_id = aws_guardduty_detector.this.id
  name        = each.value
  status      = "ENABLED"
}

# ---- Optional alerting: high-severity findings -> EventBridge -> SNS ----

resource "aws_sns_topic" "alerts" {
  count             = var.enable_alerts ? 1 : 0
  name              = "guardduty-findings"
  kms_master_key_id = var.sns_kms_key_id
  tags              = var.tags
}

data "aws_iam_policy_document" "sns" {
  count = var.enable_alerts ? 1 : 0
  statement {
    sid       = "AllowEventBridgePublish"
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.alerts[0].arn]
    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }
    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_cloudwatch_event_rule.findings[0].arn]
    }
  }
}

resource "aws_sns_topic_policy" "alerts" {
  count  = var.enable_alerts ? 1 : 0
  arn    = aws_sns_topic.alerts[0].arn
  policy = data.aws_iam_policy_document.sns[0].json
}

resource "aws_sns_topic_subscription" "email" {
  for_each  = var.enable_alerts ? toset(var.alert_emails) : toset([])
  topic_arn = aws_sns_topic.alerts[0].arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_event_rule" "findings" {
  count       = var.enable_alerts ? 1 : 0
  name        = "guardduty-findings-sev-${replace(tostring(var.alert_min_severity), ".", "-")}-plus"
  description = "GuardDuty findings with severity >= ${var.alert_min_severity}"
  event_pattern = jsonencode({
    source        = ["aws.guardduty"]
    "detail-type" = ["GuardDuty Finding"]
    detail = {
      severity = [{ numeric = [">=", var.alert_min_severity] }]
    }
  })
  tags = var.tags
}

resource "aws_cloudwatch_event_target" "sns" {
  count = var.enable_alerts ? 1 : 0
  rule  = aws_cloudwatch_event_rule.findings[0].name
  arn   = aws_sns_topic.alerts[0].arn
}
