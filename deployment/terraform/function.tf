resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.project}-${var.environment}-app-service-plan"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  kind                = "elastic"
  reserved            = true
  sku {
    tier = "ElasticPremium"
    size = "EP1"
  }
}

resource "azurerm_function_app" "function_app" {
  name                       = "${var.project}-${var.environment}-function-app"
  resource_group_name        = azurerm_resource_group.resource_group.name
  location                   = var.location
  app_service_plan_id        = azurerm_app_service_plan.app_service_plan.id
  app_settings = {
    "WEBSITE_RUN_FROM_PACKAGE"              = "",
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"   = true,
    "FUNCTIONS_WORKER_RUNTIME"              = "node",
  }
  os_type = "linux"
  storage_account_name       = azurerm_storage_account.storage_account.name
  storage_account_access_key = azurerm_storage_account.storage_account.primary_access_key
  version                    = "~3"
  auth_settings {
    enabled = true
    # https://docs.microsoft.com/en-us/azure/app-service/configure-authentication-provider-aad#-enable-azure-active-directory-in-your-app-service-app
    issuer = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0"
    default_provider = "AzureActiveDirectory"
    active_directory {
      // This points to the backend api
      client_id = azuread_application.ad_backend_app.application_id
    }
    unauthenticated_client_action = "RedirectToLoginPage"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }
}

resource "null_resource" "deploy_function" {

  # triggers = {
  #   always_run = timestamp()
  # }

  provisioner "local-exec" {
    command = <<EOF
      cd ../../functions
      npm i
      npm run build
      func azure functionapp publish ${azurerm_function_app.function_app.name} --javascript
    EOF
  }
}