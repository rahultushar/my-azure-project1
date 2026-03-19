terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

# 1. Reuse your existing resource group
resource "azurerm_resource_group" "rg" {
  name     = "keyvault-demo"
  location = "East US"
}

# 2. Create the App Service Plan (FREE TIER)
resource "azurerm_service_plan" "plan" {
  name                = "free-tier-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1" # "F1" is the code for the Free tier
}

# 3. Create the Web App
resource "azurerm_linux_web_app" "app" {
  name                = var.app_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    # CRITICAL: Free tier requires 32-bit workers
    use_32_bit_worker_process = true
    
    application_stack {
      php_version = "8.2" # We use PHP as a simple engine to serve HTML
    }
  }
}