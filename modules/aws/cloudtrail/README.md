# aws/cloudtrail

A multi-Region CloudTrail trail writing to a hardened S3 bucket (built with `s3-secure-bucket`).

- Multi-Region, global service events, **log file validation** on.
- Bucket policy only lets *this* trail write (`aws:SourceArn` condition).
- Optional KMS encryption (pass a key from `kms-key` with `cloudtrail.amazonaws.com` allowed).
- Optional CloudWatch Logs delivery for metric filters and alarms.
- Optional S3 data events and organization trail.

Maps to CIS AWS Foundations 3.1–3.7.

## Usage

```hcl
module "trail" {
  source      = "../../modules/aws/cloudtrail"
  name        = "security-trail"
  bucket_name = "acme-cloudtrail-123456789012"
  kms_key_arn = module.logs_key.key_arn
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `name` | Trail name | `org-security-trail` |
| `bucket_name` | Log bucket to create | required |
| `kms_key_arn` | KMS key for log encryption | `null` |
| `access_log_bucket` | Access-log target bucket | `null` |
| `enable_cloudwatch_logs` | Send to CloudWatch Logs | `true` |
| `cloudwatch_retention_days` | Log group retention | `365` |
| `log_s3_data_events` | Record S3 object events | `false` |
| `is_organization_trail` | Organization trail | `false` |
| `force_destroy` | Allow deleting non-empty bucket | `false` |
| `tags` | Tags | `{}` |

## Outputs

`trail_arn`, `bucket_name`, `cloudwatch_log_group_name`
