# 1. Define the Terraform Providers
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
  # Using your specific Subscription ID
  subscription_id = "c63d6c28-5d20-45ab-a3c6-92f75245b6c3"
}

# 2. Reference or Create the Resource Group
# Note: Ensure "keyvault-demo" exists or this will create it
resource "azurerm_resource_group" "rg" {
  name     = "keyvault-demo"
  location = "East US" 
}

# 3. Create the App Service Plan (Free Tier)
resource "azurerm_service_plan" "plan" {
  name                = "shopping-cart-free-plan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "F1" # F1 is the Free Tier
}

# 4. Create the Web App (The Container for your HTML)
resource "azurerm_linux_web_app" "app" {
  name                = "tush-shopping-cart-demo" # Change this if the name is taken
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  service_plan_id     = azurerm_service_plan.plan.id

  site_config {
    # CRITICAL: This MUST be inside site_config for Free Tier
    use_32_bit_worker_process = true

    application_stack {
      # We use PHP 8.2 as a simple engine to serve your index.html
      php_version = "8.2"
    }
  }

  # Optional: Settings for your app
  app_settings = {
    "APP_ENVIRONMENT" = "Demo"
  }
}

# 5. Output the Web App URL so you can click it
output "webapp_url" {
  value = "https://${azurerm_linux_web_app.app.default_hostname}"
}