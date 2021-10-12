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

// Note: if this fails you may need to manually grant admin consent: az ad app permission admin-consent --id 00000000-0000-0000-0000-000000000000
// The id being the client app client id.
resource "null_resource" "update_config" {
  triggers = {
    always_run = timestamp()
  }

  provisioner "local-exec" {
    command = <<EOF
      cd ../../ms-identity-javascript-react-spa
      npm i
      cp src/config.example.json src/config.json
      JSON_CONTENTS=$(jq '.clientId = "${azuread_application.ad_client_app.application_id}" | .authority = "https://login.microsoftonline.com/${data.azurerm_client_config.current.tenant_id}" | .scopes = [ "api://${azuread_application.ad_backend_app.display_name}/hello_world" ] | .functionHelloWorld = "${azurerm_api_management.api_management.gateway_url}/hello-world"' src/config.json)
      echo "$JSON_CONTENTS" > src/config.json
    EOF
  }
}

resource "null_resource" "admin_consent" {
  # triggers = {
  #   always_run = timestamp()
  # }

  provisioner "local-exec" {
    command = <<EOF
      az ad app permission admin-consent --id ${azuread_application.ad_client_app.application_id}
    EOF
  }
}
