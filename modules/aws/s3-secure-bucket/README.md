# aws/s3-secure-bucket

An S3 bucket with secure defaults.

| Control | Setting |
|---|---|
| Public access | All four Block Public Access settings on |
| ACLs | Disabled (`BucketOwnerEnforced`) |
| Encryption | SSE-KMS if `kms_key_arn` is set, otherwise SSE-S3 |
| Transport | Bucket policy denies non-TLS and TLS < 1.2 |
| Versioning | Enabled, old versions expire after 90 days |
| Access logs | Optional, to `access_log_bucket` |

Maps to CIS AWS Foundations 2.1.x (S3) controls.

## Usage

```hcl
module "data_bucket" {
  source      = "../../modules/aws/s3-secure-bucket"
  bucket_name = "acme-prod-data-123456789012"
  kms_key_arn = module.kms.key_arn
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `bucket_name` | Globally unique bucket name | required |
| `kms_key_arn` | KMS key for SSE-KMS | `null` |
| `access_log_bucket` | Bucket for access logs | `null` |
| `noncurrent_version_expiration_days` | Days to keep old versions | `90` |
| `additional_policy_json` | Extra policy documents to merge | `[]` |
| `force_destroy` | Delete even if not empty | `false` |
| `tags` | Tags | `{}` |

## Outputs

`bucket_id`, `bucket_arn`
