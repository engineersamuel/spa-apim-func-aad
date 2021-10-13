output "function_app_name" {
  value = azurerm_function_app.function_app.name
  description = "Deployed function app name"
}

output "function_app_default_hostname" {
  value = azurerm_function_app.function_app.default_hostname
  description = "Deployed function app hostname"
}

output "api_management_gateway_url" {
  value = azurerm_api_management.api_management.gateway_url
  description = "APIM instance gateway hostname"
}
output "ad_client_app_app_id" {
  value = azuread_application.ad_client_app.application_id
  description = "Client registration app id"
}

output "ad_backend_app_display_name" {
  value = azuread_application.ad_backend_app.display_name
  description = "Backend registration display name"
}
