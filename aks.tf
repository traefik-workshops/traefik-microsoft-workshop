data "azurerm_client_config" "this" {}

resource "azurerm_resource_group" "this" {
  name     = "traefik-${var.cluster_location}"
  location = var.cluster_location
}

resource "azurerm_kubernetes_cluster" "this" {
  name                = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  kubernetes_version  = var.aks_version
  resource_group_name = azurerm_resource_group.this.name
  dns_prefix          = replace(azurerm_resource_group.this.name, "_", "-")

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "this" {
  name                  = substr(replace(azurerm_resource_group.this.name, "-", ""), 0, 12)
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = var.cluster_machine_type
  node_count            = var.cluster_node_count
}