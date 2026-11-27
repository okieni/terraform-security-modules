# azure/activity-log

Central security logging and change alerting for a subscription.

- Creates a Log Analytics workspace (365-day retention) or uses an existing one.
- Exports all subscription Activity Log categories to it (CIS Azure 5.1.x).
- Email alerts on security-sensitive changes (CIS Azure 5.2.x): policy assignments, NSGs and NSG rules, security solutions, SQL firewall rules, public IPs, and new role assignments.

The `workspace_id` output is meant to be passed into the other Azure modules so all logs land in one place.

## Usage

```hcl
module "activity_log" {
  source              = "../../modules/azure/activity-log"
  location            = "canadacentral"
  resource_group_name = azurerm_resource_group.security.name
  alert_emails        = ["security@example.com"]
}
```

## Inputs

| Name | Description | Default |
|---|---|---|
| `location` | Region | required |
| `resource_group_name` | Resource group | required |
| `workspace_name` | Workspace to create | `law-security` |
| `existing_workspace_id` | Reuse a workspace | `null` |
| `retention_in_days` | Retention | `365` |
| `alert_emails` | Alert recipients | `[]` |
| `alert_operations` | Operations to alert on | 13 CIS operations |
| `tags` | Tags | `{}` |

## Outputs

`workspace_id`, `action_group_id`
