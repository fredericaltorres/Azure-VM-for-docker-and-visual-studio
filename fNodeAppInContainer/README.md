# How to build, test, publish and instance a container image using a NodeJS + express App on Azure

## Overview

- Here are the manual steps to create an instance of a container located in an Azure Container Registry
- The powerShell script deployContainerToAzureContainerRegistry.ps1 located in the same folder allow to
    * build an image
    * Tag and push an image to the Azure Container Registry
    * Instanciate a container instance from an image located in the Azure Container Registry

**REST API**

The NodeJS application implement the following REST API

```powershell
http://localhost:8080 # Return greeting and help in html
http://localhost:8080/api/items # Return a list of item in JSON
http://localhost:8080/api/items/1 # Return item 1 in JSON
http://localhost:8080/api/items/2 # Return item 1 in JSON
```

## How to build and test the container locally?

### How to build the container?
The build command will take the current source code,
build an image and register it into the local docker
repository under a new image id (checksum)

```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker build -t $imageTag .
# v1 - 335ee5d7fd6d
# v2 - 108e34bf4435 
docker images $imageTag
```

### How to run the image?
- Once the image is built and registered in the local docker image repository. We can create a container instance locally
and use it. 
- We will need to find the port used on the physical machine mapped to 8080.
- We can view the main log produced by the container instance
- We can also connect into the container instance itself

**Powershell Code**

```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker ps $imageTag . # Get the physical port map to 8080 in the container -> 49160
docker run -p 49160:8080 -d $imageTag

# Try this url: http://localhost:49160

# Enter the container using a bash console
docker ps # Get container ID
docker exec -it 62c7c40a51 /bin/bash 
```

### How to stop the container?
```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker stop $imageTag # stop running container
docker stop 62c7c40a51
```

## How to deploy the container in the Azure?
- First we must publish or push the container image into an Registry (Azure Container Registry).
- Frm the registry we can create multiple instance of the container image

Let's consider that the Azure Container Registry `FredContainerRegistry` already exist.

**Reference Links**

- [Install Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Tutorial: Deploy an Azure container registry and push a container image](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-tutorial-prepare-acr)
- [Azure container registry pricing](https://azure.microsoft.com/en-us/pricing/details/container-registry/)

### Tag and publish a container image into an Azure Container Registry

**Powershell Code**

```powershell
az login # if you never logged in

$imageTag = "fredericaltorres/fnodeappincontainer"
# Consider that the Azure Container `FredContainerRegistry` already exist
$acrName = "FredContainerRegistry"
$myResourceGroup = "FredContainerRegistryResourceGroup"

# Get the full login server name for your Azure container registry. 
# az acr show --name $acrName --query loginServer --output table
$acrLoginServer = "fredcontainerregistry.azurecr.io"

# With Azure Container Registry, each image pushed must be tagged according a special format
# [1-AzureContainerRegistryLoginServerName] / RegularImageTagName : Version
$newVersionTag = "v2" # << This is the new version
$newTag = "$acrLoginServer/$imageTag`:$newVersionTag" # Create a new tag with the special format

docker tag $imageTag $newTag # Tag the image locally
docker images # Look at the result

az acr login --name $acrName # Log in into the Azure Container Registry
docker push $newTag # Push tagged image to Azure Container Registry which we are currently logged in

az acr repository list --name $acrName --output table # List images in Azure Container Registry

az acr repository show-tags --name $acrName --repository $imageTag --output table # List all the tags version for a specific image in the Azure Container Registry
```

### Instantiate a container instance from an image located into an Azure Container Registry

**Powershell Code**

```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
# Consider that the Azure Container `FredContainerRegistry` already exist
$acrName = "FredContainerRegistry"
$myResourceGroup = "FredContainerRegistryResourceGroup"

# Get the full login server name for your Azure container registry. 
# az acr show --name $acrName --query loginServer --output table
$acrLoginServer = "fredcontainerregistry.azurecr.io" # In the portal see section Access Keys on the left, resource FredContainerRegistry
# Tag image with the loginServer of your container registry. 
$newVersionTag = "v3"
$newTag = "$acrLoginServer/$imageTag`:$newVersionTag"
$azureLoginName = $acrName  # In the portal see section Access Keys on the left, resource FredContainerRegistry
$azurePassword = "/HMiRc"  # In the portal see section Access Keys on the left, resource FredContainerRegistry
$containeInstanceName = "fnodeappincontainer" # Use the name of the image without my name as prefix
$dnsLabel="$containeInstanceName"

# az container xxxxx -> https://docs.microsoft.com/en-us/cli/azure/container?view=azure-cli-latest#az-container-delete

az acr login --name $acrName # Log in to container registry

# Create a container instance from the image tagged and located in the  Azure container registry.
$jsonString = az container create --resource-group $myResourceGroup --name $containeInstanceName --image $newTag --cpu 1 --memory 1 --registry-login-server $acrLoginServer --registry-username $azureLoginName --registry-password $azurePassword  --ports 8080 --os-type Linux --dns-name-label $dnsLabel

# From the json data returned by az container create, build the nodejs server url and call the url
$jsonContent = $jsonString | ConvertFrom-Json;
$fqdn = $jsonContent.ipAddress.fqdn
$ip = $jsonContent.ipAddress.ip
$port = $jsonContent.ipAddress.ports.port
$url = "http://$fqdn`:8080"
write-host "url:$url"
$apiCallResult = Invoke-RestMethod -Method Get -Uri $url
"Api returned $apiCallResult"

# Other commands to manager container instance
az container stop --resource-group $myResourceGroup --name $containeInstanceName
az container delete --resource-group $myResourceGroup --name $containeInstanceName --yes
az container start --resource-group $myResourceGroup --name $containeInstanceName
$jsonString = az container list --resource-group $myResourceGroup
$jsonString = az container show --resource-group $myResourceGroup --name $containeInstanceName
az container logs --resource-group $myResourceGroup --name $containeInstanceName
az container exec --resource-group $myResourceGroup --name $containeInstanceName --exec-command "/bin/bash"

```

