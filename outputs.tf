output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "tenant_id" {
  sensitive = true
  description = "The tenant ID of the Azure AD directory"
  value       = data.azurerm_client_config.this.tenant_id
}

output "application_client_id" {
  sensitive = true
  value = azuread_application.traefik_workshop.client_id
}

output "application_client_secret" {
  sensitive = true
  value     = azuread_application_password.traefik_workshop.value
}

output "admin_email" {
  description = "Admin email"
  value       = azuread_user.admin.user_principal_name
}
output "admin_password" {
  sensitive   = true
  description = "Admin password"
  value       = azuread_user.admin.password
}

output "support_email" {
  description = "Support email"
  value       = azuread_user.support.user_principal_name
}
output "support_password" {
  sensitive   = true
  description = "Support password"
  value       = azuread_user.support.password
}

output "external_ip" {
  description = "External IP address of the Traefik LoadBalancer service"
  value       = data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip
}

# Data source to get the Traefik service details
data "kubernetes_service" "traefik" {
  metadata {
    name      = "traefik"
    namespace = "traefik"
  }

  depends_on = [
    helm_release.traefik
  ]
}
