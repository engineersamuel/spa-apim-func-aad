resource "azuread_application" "ad_client_app" {
  display_name = "client-app"
  owners           = [ data.azuread_client_config.current.object_id ]
  sign_in_audience = "AzureADMultipleOrgs"

  single_page_application {
    redirect_uris = [ "http://localhost:3000/" ]
  }

  // This maps to API Permissions for the client
  required_resource_access {
    resource_app_id = azuread_application.ad_backend_app.application_id

    resource_access {
      id   = random_uuid.ad_backend_hello_world_scope_id.result
      type = "Scope"
    }
  }
}

resource "azuread_service_principal" "client_service_principal" {
  application_id = azuread_application.ad_client_app.application_id
  app_role_assignment_required = false
  owners = [ data.azuread_client_config.current.object_id ]
  notification_email_addresses = []
  alternative_names = []
  tags = ["backend", "service principal"]
}

# This is an optional local-exec, it's commented out as it doesn't play well with initial deployment
# resource "null_resource" "update_config" {
#   # Uncomment this to force this to run each time
#   # triggers = {
#   #   always_run = timestamp()
#   # }

#   provisioner "local-exec" {
#     command = <<EOF
#       cd ../../ms-identity-javascript-react-spa
#       npm i
#       cp src/config.example.json src/config.json
#       JSON_CONTENTS=$(jq '.clientId = "${azuread_application.ad_client_app.application_id}" | .authority = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}" | .scopes = [ "api://${azuread_application.ad_backend_app.display_name}/hello_world" ] | .functionHelloWorld = "${azurerm_api_management.api_management.gateway_url}/hello-world"' src/config.json)
#       echo "$JSON_CONTENTS" > src/config.json
#     EOF
#   }
# }

# resource "null_resource" "admin_consent" {
#   # triggers = {
#   #   always_run = timestamp()
#   # }

#   provisioner "local-exec" {
#     command = <<EOF
#       az ad app permission admin-consent --id ${azuread_application.ad_client_app.application_id}
#     EOF
#   }
# }
