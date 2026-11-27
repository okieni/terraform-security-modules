# aws/vpc-flow-logs

Turns on VPC Flow Logs for an existing VPC and locks down its default security group.

- Flow logs (ALL traffic, 60-second aggregation) to a CloudWatch log group with 1-year retention.
- Delivery role scoped to that one log group, with `aws:SourceAccount` confused-deputy protection.
- Optional KMS encryption for the log group.
- Removes every rule from the VPC's default security group (CIS 5.4).

Maps to CIS AWS Foundations 3.9 and 5.4.

## Usage

```hcl
module "flow_logs" {
  source = "../../modules/aws/vpc-flow-logs"
  vpc_id = "vpc-0123456789abcdef0"
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `vpc_id` | VPC to monitor | required |
| `traffic_type` | `ACCEPT`/`REJECT`/`ALL` | `ALL` |
| `retention_in_days` | Log retention | `365` |
| `kms_key_arn` | KMS key for the log group | `null` |
| `max_aggregation_interval` | 60 or 600 seconds | `60` |
| `restrict_default_security_group` | Empty the default SG | `true` |
| `tags` | Tags | `{}` |

## Outputs

`flow_log_id`, `log_group_name`
