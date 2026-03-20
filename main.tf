# 1. Provider Configuration
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
  subscription_id = "c63d6c28-5d20-45ab-a3c6-92f75245b6c3"
}

# 2. Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "keyvault-demo"
  location = "East US"
}

# 3. Service Plan (Linux F1 Free Tier)
resource "azurerm_service_plan" "plan" {
  name                = "shopping-cart-free-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1"
}

# 4. Linux Web App
resource "azurerm_linux_web_app" "app" {
  name                = "tush-shopping-cart-demo"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    # If Linux App Service rejects 32-bit, this is the line to remove.
    # But for F1 tier, it's usually allowed/required.
    use_32_bit_worker_process = true

    application_stack {
      php_version = "8.2"
    }
  }

  app_settings = {
    "APP_ENVIRONMENT" = "Demo"
  }
}

# 5. Output
output "webapp_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}
