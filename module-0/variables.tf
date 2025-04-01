variable "cluster_location" {
  type        = string
  default     = "westus"
  description = "AKS cluster location"
}

variable "cluster_machine_type" {
  type        = string
  default     = "Standard_F4s_v2"
  description = "Default machine type for cluster"
}

variable "cluster_node_count" {
  type        = number
  default     = 2
  description = "Number of nodes for the cluster"
}

variable "aks_version" {
  type        = string
  default     = "1.30"
  description = "AKS Kubernetes version"
}

variable "subscription_id" {
  type        = string
  description = "Azure subscription ID to use for the deployment"
}