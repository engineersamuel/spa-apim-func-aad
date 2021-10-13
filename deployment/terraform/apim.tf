resource "azurerm_api_management" "api_management" {
  name                = "${var.project}-${var.environment}-api-management"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = var.location
  publisher_name      = "Samuel Mendenhall"
  publisher_email     = "samenden@microsoft.com"
  sku_name            = "Developer_1" # Support for Consumption_0 arrives in hashicorp/azurerm v2.42.0
  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_api_management_api" "api_management_api_public" {
  name                  = "${var.project}-${var.environment}-api-management-api-public"
  api_management_name   = azurerm_api_management.api_management.name
  resource_group_name   = azurerm_resource_group.resource_group.name
  revision              = "1"
  display_name          = "Public"
  path                  = ""
  protocols             = ["https"]
  service_url           = "https://${azurerm_function_app.function_app.default_hostname}/api"
  subscription_required = false

  // This maps to the Portal APIM -> APIs -> Public -> Settings -> Security Section
  // NOTE: This is likely not necessary unless setting up auth within the APIM portal as well
  oauth2_authorization {
    authorization_server_name = azurerm_api_management_authorization_server.example.name
  }
}

resource "azurerm_api_management_api_operation" "api_management_api_operation_public_hello_world" {
  operation_id        = "public-hello-world"
  api_name            = azurerm_api_management_api.api_management_api_public.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.resource_group.name
  display_name        = "Hello World API endpoint"
  method              = "GET"
  url_template        = "/hello-world"
}

// Step 6 https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-protect-backend-with-aad#6-configure-a-jwt-validation-policy-to-pre-authorize-requests
resource "azurerm_api_management_api_policy" "api_management_api_policy_api_public" {
  api_name            = azurerm_api_management_api.api_management_api_public.name
  api_management_name = azurerm_api_management.api_management.name
  resource_group_name = azurerm_resource_group.resource_group.name

  /*
  // Example policy using Managed identity
  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <authentication-managed-identity resource="${azuread_application.ad_backend_app.application_id}" ignore-error="false" />
  </inbound>
</policies>
XML
*/

  // See https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-protect-backend-with-aad#6-configure-a-jwt-validation-policy-to-pre-authorize-requests
  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <cors allow-credentials="true">
      <allowed-origins>
        <!-- Localhost useful for development -->
        <origin>http://localhost:3000</origin>
      </allowed-origins>
      <allowed-methods preflight-result-max-age="300">
        <method>*</method>
      </allowed-methods>
      <allowed-headers>
        <header>*</header>
      </allowed-headers>
      <expose-headers>
        <header>*</header>
      </expose-headers>
    </cors>
    <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-error-message="Unauthorized. Access token is missing or invalid.">
      <openid-config url="https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0/.well-known/openid-configuration" />
      <required-claims>
        <claim name="aud">
          <value>${azuread_application.ad_backend_app.application_id}</value>
        </claim>
        <claim name="iss">
          <value>https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/v2.0</value>
        </claim>
      </required-claims>
    </validate-jwt>
  </inbound>
</policies>
XML
}

// TODO: Future feature: Enable OAuth for the APIM Developer console.
// Instructions https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-protect-backend-with-aad#4-enable-oauth-20-user-authorization-in-the-developer-console
// This section is what maps to the APIM -> OAuth 2.0 + OpenID Connection section in the portal
resource "azurerm_api_management_authorization_server" "example" {
  name                   = "test-auth-server"
  api_management_name    = azurerm_api_management.api_management.name
  resource_group_name    = azurerm_api_management.api_management.resource_group_name
  display_name           = "Test Auth Server"
  authorization_endpoint = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/authorize"
  client_id              = azuread_application.ad_client_app.application_id
  // Terraform says this is required
  client_registration_endpoint = "http://localhost"
  bearer_token_sending_methods = ["authorizationHeader"]
  // Step 7. at https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-protect-backend-with-aad#4-enable-oauth-20-user-authorization-in-the-developer-console
  grant_types = [
    "authorizationCode",
  ]

  // Step 8.b. at https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-protect-backend-with-aad#4-enable-oauth-20-user-authorization-in-the-developer-console
  authorization_methods = ["GET", "POST"]

  // Step 8.c.
  token_endpoint = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}/oauth2/v2.0/token"
}
