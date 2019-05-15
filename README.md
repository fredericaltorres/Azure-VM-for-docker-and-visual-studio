# Information about doing docker container development using Visual Studio and NodeJS from an Azure VM

## Azure VM
First we need a machine, you may install docker on our physical machine, but you can also provision an Azure VM, which is what we are doing here.

### Creation

* Create VM of type: 'Standard E4 v3' (4 vcpus, 32 GB memory), VM of type 'E* v3' comes with HyperV supported.

Reference Documents
* [Installing docker on azure virtual machine windows 10](https://stackoverflow.com/questions/44817161/installing-docker-on-azure-virtual-machine-windows-10)
* [How to enable nested virtualization in Azure](https://rlevchenko.com/2017/07/24/how-to-enable-nested-virtualization-in-azure/)

### VM Configuration
Once the VM is running connect via RDP and execute the following PowerShell commands.

```PowerShell
# Step 1 - Ensure Windows Hyper-V featutes are enabled by running PowerShell cmdlet:
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Verbose
# You should be asked to reboot.

# Step 2 - Ensure Windows Containers feature is enabled by running PowerShell cmdlet:
Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -Verbose

# Step 3 - Ensure Hypervisor is set to auto start in the Boot Configuration Database (BCD) by running in elevated command prompt the command:
bcdedit /set hypervisorlaunchtype Auto

# Reboot
```

## Docker

### Installation
Download and install Docker

- [Install Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/install)
You will be asked to log out and log in.

### Testing the Docker Installation

#### Hyper V Manager
- Start Hyper-V Manager. You should see the MobyLinuxVM running inside.
- We can increase the memory allocated to the MobyLinuxVM using the Hyper-V Manager UI.

#### Docker account
    - Create an account http://hub.docker.com
    Login: docker login # username:usual, password:cat

#### Testing local installation of Docker
```powershell
    C:\>docker version # Show the docker client side and server side
```
We expect the client side to be Windows and the server side to be Linux.
**Output**
```
Client: Docker Engine - Community
OS/Arch:           windows/amd64
Experimental:      false
Server: Docker Engine - Community
OS/Arch:          linux/amd64
```        

```powershell
C:\>docker ps # At this point to container process should be running
C:\>docker images ps # At this point to the contains repository should be enpty
```

- Let's download and execute an Hello World image
- For more information about the [Hello World Image](https://hub.docker.com/_/hello-world?tab=description)
```powershell
# Download from hub.docker.com as a default
C:\>docker pull library/hello-world 
C:\>docker run library/hello-world # execute 
C:\>docker ps --all # Show history of container execution
```

- Let's download a small version of Ubuntu
- Run the OS and execute a bash command
```powershell
# Download ubuntu and execute a bash command
C:\>docker run ubuntu /bin/bash -c "echo Hello World"
```

- Run the container in background mode, detached from the console

```powershell
C:\>docker run --detach --name helloworld  ubuntu /bin/bash -c "while true; do echo Hello World; sleep 1; done"
C:\>docker logs helloworld # see the output of the container
C:\>docker exec helloworld "uname" # run command uname inside the running container which output the name of the OS
docker stop helloworld # stop running container
```

- download the dotnet runtime and query for information
```powershell
C:\>docker run --rm -it microsoft/C:\>dotnet:2-runtime dotnet --info
```

- How to visualize information about a container image using the inspect tool?

```powershell
# How to get informaton about a docker image, used tool manifest-tool from weshigbee running in a container
C:\>docker run --rm weshigbee/manifest-tool inspect microsoft/dotnet:2-runtime
C:\>docker run --rm weshigbee/manifest-tool inspect microsoft/dotnet:2.0.0-preview1-runtime-jessie
```

## How to build and a NodeJS REST API as docker container locally and in Azure
- [Download node js](https://nodejs.org/en/download/)
- The sub folder fNodeAppInContainer, contains a NodeJS REST API application, that be containerized, published to an Azure Container Registry, and instanciate multple time int the cloud using a PowerShell Script. 
- [README](fNodeAppInContainer)

## Download Visual Studio and Git

- [Download Git](https://git-scm.com/download/win)
- [Download Visual Studio 2019 Pro or Community Edition](https://www.google.com)

## How to build and run a dot net core console as docker container locally and in Azure

- [README](./DotNetCore_Cloud_Docker_Dvt/fcoreconsole/app)

## Create an ASP.NET Core Web App, Rest API with Docker support (Not finished).
- Create an ASP.NET Core Web App, Rest API with Docker support.
    * Run inside IIS Express: https://localhost:44389/api/values
    * Run inside a container
- When running app for the first time IIS Express mode or Docker mode may fail, but run the second times.

```powershell
dotnet run # will compile and run the app from the command line

docker stop fwebapidockerized:dev # How to stop a running container 
docker stop cde304650124 # How to stop a running container

docker rmi fwebapidockerized:dev --force # how to delete an image
docker rmi cde304650133 --force # how to delete an image

# Variant 1 - how to build a container from the command line
dotnet publish -c Release
docker build -t fwebapidockerized --build-arg source=bin\Release\netcoreapp2.1\publish .

# Variant 2 - how to build a container from the command line
# How to build a docker image from a current aspnetcore project
docker build -f "C:\DVT\FWebApiDockerized\Dockerfile" -t fwebapidockerized:dev --target base --label "com.microsoft.created-by=visual-studio" "C:\DVT" 

```

### Publish to Azure Container Registry

***` - - - Not finished - - - `***


# Azure Kubernetes Service
https://www.youtube.com/watch?v=MCRJSKzdDjI

az aks install-cli

#Need a resource group fkubernetes 
az group create -n fkubernetes  -l eastus2

# -c 2 - 2 nodes   -k Kubernete version
az aks create -n fkubernetes -g fkubernetes -c 2 -k 1.7.7
# A resource group named MC_fkubernetes_fkubernetes_eastus2 is created containing all resources (vm, disk, load balancer)

# Get list of cluster
az aks list -o table

# Switch to cluster
az aks get-credentials --resource-group fkubernetes --name fkubernetes

kubectl get nodes # list all nodes or vm
kubectl get pods --all-namespaces # List pods running

# https://docs.microsoft.com/en-us/azure/aks/kubernetes-dashboard
# Open dashbord to anyone, see doc above for more security
kubectl create clusterrolebinding kubernetes-dashboard --clusterrole=cluster-admin --serviceaccount=kube-system:kubernetes-dashboard

az aks browse --resource-group fkubernetes --name fkubernetes # open dashboard
az aks browse -n fkubernetes -g fkubernetes  # open dashboard  

# Set the total of node to 3 -> add one more vm
az aks scale --resource-group fkubernetes -n fkubernetes --agent-count 3

az aks get-versions --location eastus2 -o table

kubectl config use-context fkubernetes # Switch to cluster

# How to instanciate a container from ACR into Kubenetes
# https://thorsten-hans.com/how-to-use-private-azure-container-registry-with-kubernetes
# Define the ACR registry as a docker secret
kubectl create secret docker-registry fredcontainerregistry --docker-server fredcontainerregistry.azurecr.io --docker-email fredericaltorres@gmail.com --docker-username=FredContainerRegistry --docker-password "/HMiRc"

#Docker image in ACR: fredcontainerregistry.azurecr.io/fcoreconsoleazurestorage:1.0.29    

Create file:pod-sample.yaml
apiVersion: v1
kind: Pod
metadata:
  name: private-fcoreconsoleazurestorage
spec:
  containers:
  - name: private-container-fcoreconsoleazurestorage
    image: fredcontainerregistry.azurecr.io/fcoreconsoleazurestorage:1.0.29
  imagePullSecrets:
  - name: fredcontainerregistry

# Run the following to create an instance of the container
C:\>kubectl create -f pod-sample.yaml
kubectl describe pod private-fcoreconsoleazurestorage

# Delete running pod or container
kubectl delete -f pod-sample.yaml

# https://kubernetes.io/docs/reference/kubectl/cheatsheet/

# Get all running pods or container in the namespace
kubectl get pods --field-selector=status.phase=Running

# Get Log
kubectl logs private-fcoreconsoleazurestorage
# Stream log
kubectl logs -f private-fcoreconsoleazurestorage

# Run command in pod
kubectl exec private-fcoreconsoleazurestorage -- ls /app/tutu

