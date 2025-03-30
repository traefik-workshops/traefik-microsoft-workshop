![AKS](../media/aks.png)

## Introduction

In this module, we will deploy an AKS cluster using AZ CLI. Traefik Hub will claim the cluster for easier management of APIs. 

#### Prerequisites

- kubectl installed on your laptop. See [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/) for installation instructions
- AZ CLI tools installed. See [here](https://learn.microsoft.com/en-us/cli/azure/install-azure-cli#install) for installation instructions.

#### Deploy a Kubernetes Cluster with the Azure CLI

1. Log in to your Azure account. The below command should open a new browser. Log in with your Azure credentials. 

```bash
az login
```

2. You can verify your subscription details and change subscriptions if needed using the below commands:

```bash
# View subscriptions
az account list --out table

# Verify selected subscription
az account show --out table

# Set the correct subscription (if needed)
az account set --subscription <subscription_id>

# Verify that the correct subscription is now set
az account show --out table
```

3. Define the variables we will utilize below during Kubernetes cluster creation. 

```bash
export CLUSTER_NAME=                            # example: firstName-lastName
export AKS_RESOURCE_GROUP=$CLUSTER_NAME         # example: we will use the same name for our resource group. 
export AKS_REGION=                              # example: westus, centralus, eastus. For the full list, "az account list-locations --output table"
export KUBECONFIG=                              # example: ~/.kube/$CLUSTER_NAME.yaml
```

4. Create a resource group that would hold all AKS resources associated with this cluster

```bash
az group create -n $AKS_RESOURCE_GROUP -l $AKS_REGION
```

5. Create a production-ready Kubernetes cluster using a single command

```bash
az aks create --resource-group $AKS_RESOURCE_GROUP --name $CLUSTER_NAME --node-count 2 --ssh-key=~/.ssh/id_rsa.pub 
```

6. Retrieve AKS credentials so you can manage the cluster from your laptop.

```bash
az aks get-credentials --resource-group $AKS_RESOURCE_GROUP --name $CLUSTER_NAME --file $KUBECONFIG
```

7. Verify access to the AKS cluster

```bash
kubectl get nodes
```

------
:house: [HOME](../README.md) | :arrow_forward: [Module 1: Traefik Application Proxy](../module-1/readme.md)
