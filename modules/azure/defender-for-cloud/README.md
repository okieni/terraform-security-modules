# azure/defender-for-cloud

Turns on Microsoft Defender for Cloud for the current subscription.

- Standard tier for VMs, Storage, Key Vault, ARM, SQL, App Service, Containers and CSPM (configurable).
- Security contact with alert emails to you and subscription owners (CIS Azure 2.1.x).
- Optional assignment of the Microsoft Cloud Security Benchmark initiative.

> **Cost:** Defender plans are billed per resource. Trim `plans` for labs.

## Usage

```hcl
module "defender" {
  source                 = "../../modules/azure/defender-for-cloud"
  security_contact_email = "security@example.com"
  plans                  = ["KeyVaults", "StorageAccounts", "Arm", "CloudPosture"]
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `plans` | Defender plans | 8 common plans |
| `security_contact_email` | Alert email | `null` |
| `security_contact_phone` | Contact phone | `null` |
| `assign_mcsb` | Assign MCSB initiative | `false` |

## Outputs

`enabled_plans`
