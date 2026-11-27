terraform {
  required_version = ">= 1.5"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.0, < 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.5"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id     = var.subscription_id
  storage_use_azuread = true # shared keys are disabled on the storage account
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

locals {
  tags = {
    ManagedBy = "terraform"
    Purpose   = "security-baseline"
  }
}

resource "azurerm_resource_group" "security" {
  name     = "rg-security-baseline"
  location = var.location
  tags     = local.tags
}

# 1. Central Log Analytics workspace + Activity Log export + change alerts.
module "activity_log" {
  source              = "../../modules/azure/activity-log"
  location            = var.location
  resource_group_name = azurerm_resource_group.security.name
  alert_emails        = var.alert_emails
  tags                = local.tags
}

# 2. Defender for Cloud (trimmed plan list to keep lab costs down).
module "defender" {
  source                 = "../../modules/azure/defender-for-cloud"
  plans                  = ["KeyVaults", "StorageAccounts", "Arm", "CloudPosture"]
  security_contact_email = length(var.alert_emails) > 0 ? var.alert_emails[0] : null
}

# 3. Hardened Key Vault with audit logs.
module "key_vault" {
  source                     = "../../modules/azure/key-vault"
  name                       = "kv-sec-${random_string.suffix.result}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.security.name
  allowed_ip_ranges          = var.allowed_ip_ranges
  log_analytics_workspace_id = module.activity_log.workspace_id
  tags                       = local.tags
}

# 4. Hardened storage account.
module "storage" {
  source                     = "../../modules/azure/storage-account"
  name                       = "stsec${random_string.suffix.result}"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.security.name
  allowed_ip_ranges          = var.allowed_ip_ranges
  log_analytics_workspace_id = module.activity_log.workspace_id
  tags                       = local.tags
}

# 5. Deny-by-default NSG that only allows HTTPS in.
module "web_nsg" {
  source                     = "../../modules/azure/nsg-baseline"
  name                       = "nsg-web"
  location                   = var.location
  resource_group_name        = azurerm_resource_group.security.name
  log_analytics_workspace_id = module.activity_log.workspace_id
  tags                       = local.tags

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
