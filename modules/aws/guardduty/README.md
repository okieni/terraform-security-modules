# aws/guardduty

Turns on Amazon GuardDuty threat detection in the current Region, with alerting.

- Detector enabled, findings published every 15 minutes.
- Protection plans: S3, EKS audit logs, EBS malware scanning, RDS login events, Lambda network logs (configurable).
- High-severity findings (default ≥ 7) routed through EventBridge to an SNS topic (KMS-encrypted when you pass `sns_kms_key_id`), with optional email subscribers.

GuardDuty is Regional — call the module once per Region (with a provider alias).

## Usage

```hcl
module "guardduty" {
  source       = "../../modules/aws/guardduty"
  alert_emails = ["security@example.com"]
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `finding_publishing_frequency` | Publishing frequency | `FIFTEEN_MINUTES` |
| `features` | Protection plans | S3, EKS, EBS, RDS, Lambda |
| `enable_alerts` | Create SNS alerting | `true` |
| `alert_min_severity` | Minimum severity | `7` |
| `alert_emails` | Email subscribers | `[]` |
| `sns_kms_key_id` | Customer managed key for SNS (must allow `events.amazonaws.com`; the AWS managed SNS key won't work with EventBridge) | `null` |
| `tags` | Tags | `{}` |

## Outputs

`detector_id`, `alert_topic_arn`
