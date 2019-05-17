# Azure Kubernetes Service

## Overview
The document describes how to start with Azure Kubernetes Service.

### Videos
* [Azure: "Kubernetes the Easy Way" Managed Kubernetes on Azure AKS | E101](https://www.youtube.com/watch?v=MCRJSKzdDjI)
* [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### Setup
* Install the Azure Kubernetes Service (aks) for the az command line
```
c:\>az aks install-cli
```

### Creation of the Kubernetes cluster
* A cluster can be created from the portal or the command line
* A cluster cost money, becare full to delete it or shutdown the VM (AKA Pods)
```powershell
az group create -n fkubernetes  -l eastus2 # Create a resource group fkubernetes
# Create the cluster
# -c 2 - 2 nodes   -k Kubernete version
az aks create -n fkubernetes -g fkubernetes -c 2 -k 1.7.7
```
* A resource group named MC_fkubernetes_fkubernetes_eastus2 will be created containing all resources (vm, disk, load balancer).

### More commands once the cluster is created
```powershell
az aks list -o table # Get list of clusters
az aks get-credentials --resource-group fkubernetes --name fkubernetes # Switch to cluster
```

#### Setup kubectl.exe
The Kubernetes command-line tool, kubectl, allows you to run commands against Kubernetes clusters. 
- [Install and Set Up kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

```powershell
kubectl get nodes # Get the list all nodes or vm
kubectl get pods --all-namespaces # List pods running
kubectl version # Get version of client and server Kubernetes
```
### Kubernetes dashboard
* Open dashbord to anyone, see doc below for more security, execute command below, this is new not well documented
* [Access the Kubernetes web dashboard in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/kubernetes-dashboard)
 
```powershell
# Authorize anybody to be admin on the cluster dashboard
C:\> kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard
az aks browse --resource-group fkubernetes --name fkubernetes # Start web server dashboard and open in browser
az aks browse -n fkubernetes -g fkubernetes  # open dashboard    # Start web server dashboard and open in browser
```
### Add one more vm (node)
```powershell
# The cluster was created with 2 agents or node or vm, we now set the number to 3
# The default vm configuration is used
az aks scale --resource-group fkubernetes -n fkubernetes --agent-count 3
```

```powershell
# List of version of kubernetes available and the upgrade path
az aks get-versions --location eastus2 -o table
```

### Switch to a specific cluster
```powershell
kubectl config use-context fkubernetes # Switch to cluster
C:\> kubectl get services
```

### How to instanciate a container image from an Azure Container Registry into a Kubernetes cluster

* [How to use a private Azure Container Registry with Kubernetes](https://thorsten-hans.com/how-to-use-private-azure-container-registry-with-kubernetes)

1. Register the Azure Container Registry into the Kubernetes cluster
```powershell
# Define the ACR registry as a docker secret
C:\> kubectl create secret docker-registry fredcontainerregistry --docker-server fredcontainerregistry.azurecr.io --docker-email fredericaltorres@gmail.com --docker-username=FredContainerRegistry --docker-password "izBEjxfFrep"
```

1. Create a pod-sample.yaml file

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: fcoreconsoleazurestorage # name to reference the instance
spec:
  containers:
  - name: container-fcoreconsoleazurestorage
    image: fredcontainerregistry.azurecr.io/fcoreconsoleazurestorage:1.0.31
  imagePullSecrets:
  - name: fredcontainerregistry
```  


1. Execute the command to instanciate the container image into a pod
```powershell

C:\> kubectl create -f pod-sample.1.yaml # instanciate the container image into a pod
C:\> kubectl create -f pod-sample.2.yaml # instanciate a second instance of the container image into a pod

C:\> kubectl describe pod fcoreconsoleazurestorage1
C:\> kubectl describe pod fcoreconsoleazurestorage2

C:\> kubectl get deployments # get the information about the deployment

C:\> kubectl get pods # Get all the pod
C:\> kubectl get pods --field-selector=status.phase=Running # Get all running pods or container in the namespace

C:\> kubectl logs fcoreconsoleazurestorage1 # Get Log
C:\> kubectl logs fcoreconsoleazurestorage2 # Get Log

C:\> kubectl logs -f fcoreconsoleazurestorage # Stream log
C:\> kubectl exec fcoreconsoleazurestorage -- ls /app/tutu # Run command in pod

C:\> kubectl delete -f pod-sample.1.yaml # Delete running pod or container using the yaml file
C:\> kubectl delete -f pod-sample.2.yaml # Delete running pod or container

C:\> kubectl delete pod fcoreconsoleazurestorage1 # Delete running pod or container using the name
C:\> kubectl delete pod fcoreconsoleazurestorage2 # Delete running pod or container using the name
```

### Kubernetes depoyment concept

 # https://devopscube.com/kubernetes-deployment-tutorial/
kubectl create -f pod-deployment.yaml


## Kubernetes.io tutorials
- [Interactive Tutorial - Deploying an App](https://kubernetes.io/docs/tutorials/kubernetes-basics/deploy-app/deploy-interactive/)
```bash

kubectl run kubernetes-bootcamp --image=gcr.io/google-samples/kubernetes-bootcamp:v1 --port=8080
# kubectl run --generator=deployment/apps.v1 is DEPRECATED and will be removed in a future version. Use 
# kubectl run --generator=run-pod/v1 or kubectl create instead.
kubectl proxy
curl http://localhost:8001/version


kubectl proxy # rer
```