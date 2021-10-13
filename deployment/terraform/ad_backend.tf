data "azuread_client_config" "current" {}

resource "azuread_application" "ad_backend_app" {
  display_name             = "${var.project}-${var.environment}-backend-app"
  identifier_uris          = ["api://${var.project}-${var.environment}-backend-app"]
  owners                   = [data.azuread_client_config.current.object_id]
  prevent_duplicate_names  = true
  sign_in_audience = "AzureADandPersonalMicrosoftAccount"

  group_membership_claims = ["SecurityGroup"]

  api {
    mapped_claims_enabled          = true
    requested_access_token_version = 2

    // This section maps to https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-protect-backend-with-aad#3-grant-permissions-in-azure-ad
    // Which is for "granting permissions to allow the client-app to call the backend-app"
    /*
    known_client_applications = [
      azuread_application.ad_client_app.application_id
    ]
    */

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access example on behalf of the signed-in user."
      admin_consent_display_name = "Access example"
      enabled                    = true
      id                         = random_uuid.ad_backend_hello_world_scope_id.result
      type                       = "User"
      user_consent_description   = "Allow the application to access example on your behalf."
      user_consent_display_name  = "Access example"
      value                      = "hello_world"
    }
  }
}

resource "azuread_service_principal" "backend_service_principal" {
  application_id = azuread_application.ad_backend_app.application_id
  app_role_assignment_required = false
  owners = [ data.azuread_client_config.current.object_id ]
  notification_email_addresses = []
  alternative_names = []
  tags = ["backend", "service principal"]
}

// https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/resources/application_pre_authorized
// This maps to the "Authorized client applications" within the Portal.
/*
resource "azuread_application_pre_authorized" "this" {
  // Backend
  application_object_id = azuread_application.ad_backend_app.object_id
  // Client
  authorized_app_id     = azuread_application.ad_client_app.application_id
  // These ids were from terraform, why are they hardcoded?
  permission_ids        = [ random_uuid.ad_backend_hello_world_scope_id.result ]
}*/