# aws/account-baseline

Account-level guardrails you set once per account (and per Region where noted).

| Control | CIS AWS v3.0 |
|---|---|
| IAM password policy: 14+ chars, complexity, 24 reuse prevention | 1.8, 1.9 |
| Account-wide S3 Block Public Access | 2.1.4 |
| EBS encryption by default (Regional) | 2.2.1 |
| IAM Access Analyzer (Regional) | 1.20 |
| Security Hub + FSBP and CIS v3.0 standards (Regional) | 4.16 / monitoring |

## Usage

```hcl
module "baseline" {
  source = "../../modules/aws/account-baseline"
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `minimum_password_length` | Min password length (≥14) | `14` |
| `max_password_age` | Password expiry days, 0 = never | `0` |
| `ebs_kms_key_arn` | CMK for default EBS encryption | `null` |
| `enable_access_analyzer` | Create Access Analyzer | `true` |
| `access_analyzer_name` | Analyzer name | `account-access-analyzer` |
| `access_analyzer_type` | `ACCOUNT` / `ORGANIZATION` | `ACCOUNT` |
| `enable_security_hub` | Enable Security Hub | `true` |
| `tags` | Tags | `{}` |

## Outputs

`access_analyzer_arn`, `security_hub_standards`
