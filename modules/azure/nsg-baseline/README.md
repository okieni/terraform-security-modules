# azure/nsg-baseline

A network security group with a deny-by-default posture and a built-in guardrail.

- **Validation blocks the plan** if any rule opens SSH (22) or RDP (3389) — or all ports — to the internet (CIS Azure 6.1, 6.2).
- Explicit `DenyAllInbound` at priority 4096, so traffic is allowed only by rules you write.
- Optional subnet associations and diagnostic logs.

## Usage

```hcl
module "web_nsg" {
  source              = "../../modules/azure/nsg-baseline"
  name                = "nsg-web"
  location            = "canadacentral"
  resource_group_name = azurerm_resource_group.network.name
  subnet_ids          = [azurerm_subnet.web.id]

  rules = [
    {
      name                   = "AllowHttpsInbound"
      priority               = 100
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "Tcp"
      destination_port_range = "443"
      source_address_prefix  = "Internet"
    },
  ]
}
```

Try adding a rule with `destination_port_range = "22"` and `source_address_prefix = "*"` — `terraform plan` will fail with a clear error.

## Inputs

| Name | Description | Default |
|---|---|---|
| `name` | NSG name | required |
| `location` | Region | required |
| `resource_group_name` | Resource group | required |
| `rules` | Custom rules (priority 100–4095) | `[]` |
| `deny_all_inbound` | Add DenyAllInbound at 4096 | `true` |
| `subnet_ids` | Subnets to associate | `[]` |
| `log_analytics_workspace_id` | Log destination | `null` |
| `tags` | Tags | `{}` |

## Outputs

`id`, `name`
