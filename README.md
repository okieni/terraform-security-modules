# Terraform Security Modules

Reusable Terraform modules that deploy **secure-by-default** cloud building blocks on **AWS** and **Azure**, mapped to the CIS Foundations Benchmarks.

Every module ships with hardened defaults, input validation that blocks insecure settings at `plan` time, and its own README. CI runs `terraform fmt`, `terraform validate`, **tflint** and a **Checkov** security scan on every push.

## Modules

### AWS

| Module | What it does | CIS AWS v3.0 |
|---|---|---|
| [`s3-secure-bucket`](modules/aws/s3-secure-bucket) | Private, encrypted, versioned bucket; denies non-TLS and TLS < 1.2 | 2.1.x |
| [`kms-key`](modules/aws/kms-key) | CMK with rotation and separated admin/user roles | 3.6 |
| [`cloudtrail`](modules/aws/cloudtrail) | Multi-Region trail, log validation, KMS, CloudWatch Logs | 3.1–3.7 |
| [`guardduty`](modules/aws/guardduty) | Threat detection + protection plans + high-severity alerts | — |
| [`account-baseline`](modules/aws/account-baseline) | Password policy, S3 BPA, EBS encryption, Access Analyzer, Security Hub | 1.8, 1.9, 1.20, 2.1.4, 2.2.1 |
| [`vpc-flow-logs`](modules/aws/vpc-flow-logs) | VPC Flow Logs + locked-down default security group | 3.9, 5.4 |

### Azure

| Module | What it does | CIS Azure |
|---|---|---|
| [`key-vault`](modules/azure/key-vault) | RBAC, purge protection, firewall deny, private endpoint, audit logs | 8.x |
| [`storage-account`](modules/azure/storage-account) | TLS 1.2, no public/shared-key access, double encryption, soft delete | 3.x |
| [`nsg-baseline`](modules/azure/nsg-baseline) | Deny-by-default NSG; **blocks SSH/RDP from the internet** | 6.1, 6.2 |
| [`defender-for-cloud`](modules/azure/defender-for-cloud) | Defender plans + security contact + MCSB | 2.1.x |
| [`activity-log`](modules/azure/activity-log) | Log Analytics, Activity Log export, change alerts | 5.1.x, 5.2.x |

## Quick start

Full working examples that wire the modules together:

- [`examples/aws-baseline`](examples/aws-baseline) — KMS → CloudTrail, GuardDuty, account baseline, flow logs
- [`examples/azure-baseline`](examples/azure-baseline) — Log Analytics, Defender, Key Vault, Storage, NSG

```bash
cd examples/aws-baseline
terraform init
terraform plan -var='alert_emails=["you@example.com"]'
```

```bash
cd examples/azure-baseline
terraform init
terraform plan -var="subscription_id=<your-subscription-id>" -var='allowed_ip_ranges=["<your-public-ip>"]'
```

Use a module directly from GitHub:

```hcl
module "bucket" {
  source      = "github.com/<your-github-username>/terraform-security-modules//modules/aws/s3-secure-bucket?ref=v0.1.0"
  bucket_name = "my-secure-bucket-123"
}
```

## Design principles

- **Secure by default** — you opt *out* of a control, never in.
- **Fail at plan time** — `validation` blocks reject insecure inputs (e.g. port 22 open to `*`).
- **Least privilege** — IAM/KMS policies are scoped to one resource and use confused-deputy conditions (`aws:SourceArn`, `aws:SourceAccount`).
- **Log everything centrally** — modules accept a log destination and send audit logs to it.
- **Composable** — e.g. `cloudtrail` builds its bucket with `s3-secure-bucket`.

## Requirements

| Tool | Version |
|---|---|
| Terraform | >= 1.5 |
| AWS provider | >= 5.50 |
| AzureRM provider | >= 4.0, < 5.0 |

## Cost note

GuardDuty, Security Hub, Defender for Cloud, KMS keys and log retention are billed. Destroy lab environments with `terraform destroy` when you're done. Note that the KMS key enters a 30-day deletion window, and Key Vault purge protection keeps the vault name reserved for the soft-delete period.

## License

MIT
