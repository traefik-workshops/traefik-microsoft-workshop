# Create users
resource "azuread_user" "admin" {
  user_principal_name = "admin@${data.azuread_domains.default.domains[0].domain_name}"
  display_name        = "Admin"
  password           = "topsecretpassword"
  force_password_change = false
  disable_strong_password = true
}

resource "azuread_user" "support" {
  user_principal_name = "support@${data.azuread_domains.default.domains[0].domain_name}"
  display_name        = "Support"
  password           = "topsecretpassword"
  force_password_change = false
  disable_strong_password = true
}

# Create groups
resource "azuread_group" "admin" {
  display_name     = "admin"
  security_enabled = true
}

resource "azuread_group" "support" {
  display_name     = "support"
  security_enabled = true
}

# Add users to their respective groups
resource "azuread_group_member" "admin" {
  group_object_id  = azuread_group.admin.object_id
  member_object_id = azuread_user.admin.object_id
}

resource "azuread_group_member" "support" {
  group_object_id  = azuread_group.support.object_id
  member_object_id = azuread_user.support.object_id
}

# Get default domain
data "azuread_domains" "default" {
  only_default = true
}

# Create app registration
resource "azuread_application" "traefik_workshop" {
  display_name = "traefik-workshop"
  identifier_uris = ["api://c51d02df-7bc5-4478-a41f-86c743ac783c"]
  
  # Configure optional claims and group membership claims
  optional_claims {
    access_token {
      name = "groups"
      essential = true
    }
  }
  
  group_membership_claims = ["All"]

  web {
    homepage_url = "https://whoami.traefik.${data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip}.sslip.io"
    redirect_uris = [
      "https://whoami.traefik.${data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip}.sslip.io/cback",
      "https://demo-portal.traefik.${data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip}.sslip.io/callback"
    ]
    implicit_grant {
      access_token_issuance_enabled = true
      id_token_issuance_enabled     = true
    }
  }

  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph

    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
    resource_access {
      id   = "37f7f235-527c-4136-accd-4a02d197296e" # openid
      type = "Scope"
    }
    resource_access {
      id   = "7427e0e9-2fba-42fe-b0c0-848c9e6a8182" # offline_access
      type = "Scope"
    }
    resource_access {
      id   = "62a82d76-70ea-41e2-9197-370581804d09" # Group.Read.All
      type = "Role"
    }
  }

  # Add API scope
  api {
    mapped_claims_enabled = true
    known_client_applications = []

    oauth2_permission_scope {
      admin_consent_description  = "Allow the application to access group membership information"
      admin_consent_display_name = "Access Groups"
      enabled                   = true
      id                        = "00000000-0000-0000-0000-000000000003"
      type                      = "User"
      user_consent_description  = "Allow this application to access your group membership information"
      user_consent_display_name = "Access your groups"
      value                     = "groups"
    }
  }

  # Define app roles
  app_role {
    allowed_member_types = ["User", "Application"]
    description          = "Admin role for full access"
    display_name         = "Admin"
    enabled              = true
    id                   = "00000000-0000-0000-0000-000000000001" # Custom UUID
    value                = "admin"
  }

  app_role {
    allowed_member_types = ["User", "Application"]
    description          = "Support role for limited access"
    display_name         = "Support"
    enabled              = true
    id                   = "00000000-0000-0000-0000-000000000002" # Custom UUID
    value                = "support"
  }
}

# Create client secret
resource "azuread_application_password" "traefik_workshop" {
  application_id = azuread_application.traefik_workshop.id
  display_name   = "traefik-workshop-secret"
  end_date       = "2050-12-31T00:00:00Z"  # Set expiry date
}

# Create service principal for the application
resource "azuread_service_principal" "traefik_workshop" {
  client_id = azuread_application.traefik_workshop.client_id
}

# Assign roles to users
resource "azuread_app_role_assignment" "admin_role" {
  app_role_id         = [for role in azuread_application.traefik_workshop.app_role : role.id if role.value == "admin"][0]
  principal_object_id = azuread_user.admin.object_id
  resource_object_id  = azuread_service_principal.traefik_workshop.object_id
}

resource "azuread_app_role_assignment" "support_role" {
  app_role_id         = [for role in azuread_application.traefik_workshop.app_role : role.id if role.value == "support"][0]
  principal_object_id = azuread_user.support.object_id
  resource_object_id  = azuread_service_principal.traefik_workshop.object_id
}
