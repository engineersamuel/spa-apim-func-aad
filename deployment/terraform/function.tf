resource "azurerm_app_service_plan" "app_service_plan" {
  name                = "${var.project}-${var.environment}-app-service-plan"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  kind                = "FunctionApp"
  // kind             = "Linux"
  // reserved         = true
  sku {
    tier = "Dynamic" // "ElasticPremium"
    size = "Y1" // "EP1"
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
    "WEBSITE_NODE_DEFAULT_VERSION"          = "~14"
  }
  # When set to "linux" this forces replacement on apply
  #os_type = "linux"
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
      // TODO: Add aud?
    }
    unauthenticated_client_action = "RedirectToLoginPage"
  }

  lifecycle {
    ignore_changes = [
      app_settings["WEBSITE_RUN_FROM_PACKAGE"],
    ]
  }

}

# This is an optional local-exec, it's commented out as it doesn't play well with initial deployment
# resource "null_resource" "deploy_function" {
#   # triggers = {
#   #   always_run = timestamp()
#   # }
#   provisioner "local-exec" {
#     command = <<EOF
#       cd ../../functions
#       npm i
#       npm run build
#       func azure functionapp publish ${azurerm_function_app.function_app.name} --javascript
#     EOF
#   }
# }