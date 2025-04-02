<br/>

<div align="center" style="margin: 30px;">
  <img src="https://upload.wikimedia.org/wikipedia/commons/thumb/8/8c/Microsoft_Entra_ID_color_icon.svg/1920px-Microsoft_Entra_ID_color_icon.svg.png"   style="width:250px;" align="center" />
</a>
<br />
</div>

# Microsoft Entra ID Integration

This module uses Terraform to configure Microsoft Entra ID (formerly Azure AD) integration with Traefik Hub. The following resources are automatically provisioned:

## Users and Groups
- Two demo users (admin, support) with their respective groups
- Each user is assigned to their corresponding group (e.g., admin user → admin group)
- Default password for all users: `topsecretpassword`

## Application Registration
- Name: traefik-workshop
- Authentication: OpenID Connect
- Configured with necessary Microsoft Graph permissions:
  - openid
  - profile
  - email
  - offline_access
  - User.Read
- Implicit grant flow enabled for access tokens and ID tokens
- Redirect URIs configured for Traefik Hub integration

## Role-Based Access Control
- Two application roles defined:
  - Admin: Full access
  - Support: Limited access
- Each user is automatically assigned their corresponding role

All configuration is managed through Terraform in the `entraid.tf` file, ensuring consistent and reproducible deployments.

------
:house: [HOME](../README.md) | :twisted_rightwards_arrows: [Return to module 2: Traefik Hub API Gateway](../module-2/readme.md#secure-access-to-your-application)
