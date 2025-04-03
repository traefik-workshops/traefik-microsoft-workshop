## Introduction

This module uses Terraform to automatically deploy and configure:
- Azure Kubernetes Service (AKS) cluster with multiple node pools
- Microsoft Entra ID (formerly Azure AD) with users, groups, and RBAC
- Traefik as the ingress controller with API Gateway capabilities

The infrastructure is designed to support the subsequent modules in this workshop, with security and scalability in mind.

#### Prerequisites
- AZ CLI. See [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli#install) for installation instructions.
- Terraform. See [here](https://developer.hashicorp.com/terraform/install) for installation instructions.
- kubectl. See [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for installation instructions.

1. Clone git repo into your client.

```bash
git clone git@github.com:traefik-workshops/traefik-microsoft-workshop.git
cd traefik-microsoft-workshop
```

#### Deploy a Kubernetes Cluster using Terraform

2. Log in to your Azure account. The below command should open a new browser. Log in with your Azure credentials. 

```bash
az login
```

3. Get your subscription ID. You'll need this for the Terraform configuration.

List all available subscriptions:
```bash
az account list --output table
```

Optional: Switch to a different subscription if needed:
```bash
az account set --subscription <subscription-id>
```

4. Initialize Terraform

```bash
terraform init
```

5. Deploy the cluster

```bash
terraform apply -auto-approve -var="subscription_id=$(az account show --query id -o tsv)"
```

6. Get AKS credentials and connect to the cluster

```bash
export RESOURCE_GROUP=$(terraform output -raw resource_group_name)
export CLUSTER_NAME=$(terraform output -raw cluster_name)
az aks get-credentials  --overwrite-existing --resource-group $RESOURCE_GROUP --name $CLUSTER_NAME
```

7. Verify the connection

```bash
kubectl get nodes
```

------
:house: [HOME](../README.md) | :arrow_forward: [Module 1: Traefik Application Proxy](../module-1/readme.md)