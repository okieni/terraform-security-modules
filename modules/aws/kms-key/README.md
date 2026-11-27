# aws/kms-key

A customer managed KMS key with a least-privilege key policy.

- Automatic key rotation is always on (period configurable, default 365 days).
- Separate **administrators** (manage the key) and **users** (encrypt/decrypt), so admins can't read data.
- Optional AWS service access, restricted with `aws:SourceAccount` to stop confused-deputy use.
- 30-day deletion window by default.

## Usage

```hcl
module "logs_key" {
  source             = "../../modules/aws/kms-key"
  alias              = "security-logs"
  service_principals = ["cloudtrail.amazonaws.com", "logs.ca-central-1.amazonaws.com"]
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `alias` | Alias without `alias/` | required |
| `description` | Key description | generic |
| `key_admin_arns` | Admin principals | account root |
| `key_user_arns` | Encrypt/decrypt principals | `[]` |
| `service_principals` | AWS services allowed to use the key | `[]` |
| `rotation_period_in_days` | 90–2560 | `365` |
| `deletion_window_in_days` | 7–30 | `30` |
| `multi_region` | Multi-Region key | `false` |
| `tags` | Tags | `{}` |

## Outputs

`key_arn`, `key_id`, `alias_arn`
