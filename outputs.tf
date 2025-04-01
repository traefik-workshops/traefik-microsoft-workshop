output "resource_group_name" {
  description = "The name of the resource group"
  value       = azurerm_resource_group.this.name
}

output "cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "admin_user_principal_name" {
  value = azuread_user.admin.user_principal_name
}

output "developer_user_principal_name" {
  value = azuread_user.developer.user_principal_name
}

output "maintainer_user_principal_name" {
  value = azuread_user.maintainer.user_principal_name
}

output "admin_group_id" {
  value = azuread_group.admin.id
}

output "developer_group_id" {
  value = azuread_group.developer.id
}

output "maintainer_group_id" {
  value = azuread_group.maintainer.id
}

output "application_client_id" {
  value = azuread_application.traefik_workshop.client_id
}

output "application_object_id" {
  value = azuread_application.traefik_workshop.object_id
}

output "application_client_secret" {
  value     = azuread_application_password.traefik_workshop.value
  sensitive = true
}

output "external_ip" {
  description = "External IP address of the Traefik LoadBalancer service"
  value       = data.kubernetes_service.traefik.status.0.load_balancer.0.ingress.0.ip
}

output "tenant_id" {
  description = "The tenant ID of the Azure AD directory"
  value       = data.azurerm_client_config.this.tenant_id
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
