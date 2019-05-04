# Fred Node App In Container

## How to build the container

```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker build -t $imageTag .
docker images $imageTag
```

## How to run the image

```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker run -p 49160:8080 -d $imageTag
3474e4f9c8738ec1fe37f5a164e09e01e0c8e9c1bfbcd4f1ba2a61d7e9cf97dd

docker ps # Get container ID

docker logs 3474e4f9c873    # Print app output

$ docker exec -it 3474e4f9c873 /bin/bash # Enter the container

```

## Test the app
To test your app, get the port of your app that Docker mapped:
`
```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker ps $imageTag .
# Get the physical port map to 8080 in the container -> 49160

# Try this url: http://localhost:49160
```

## How to stop the container
```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker stop $imageTag # stop running container
docker stop 3474e4f9c873
```

## How to deploy the container in the cloud

First, we will create an Azure container registry and push our container image

- [Install Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Tutorial: Deploy an Azure container registry and push a container image](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-tutorial-prepare-acr)
- [Azure container registry pricing](https://azure.microsoft.com/en-us/pricing/details/container-registry/)


```powershell
az login # if you never logged in
$myResourceGroup = "fnodeappincontainerResourceGroup"
az group create --name $myResourceGroup --location eastus

# Create an Azure container registry -- SKU BASIC $61 / year
# 
$acrName = "fnodeappincontainerContainerRegistry"
az acr create --resource-group  $myResourceGroup --name $acrName --sku Basic --admin-enabled true

# Log in to container registry
az acr login --name $acrName

# Get the full login server name for your Azure container registry. 
az acr show --name $acrName --query loginServer --output table
$acrLoginServer = "fnodeappincontainercontainerregistry.azurecr.io"
$imageTag = "fredericaltorres/fnodeappincontainer"

# Tag image with the loginServer of your container registry. 
$newTag = "$acrLoginServer/$imageTag`:v1"
docker tag $imageTag $newTag 

# Push tagged image to registry
docker push $newTag


# List images in Azure Container Registry
az acr repository list --name $acrName --output table

# To see the tags version for a specific image, 
az acr repository show-tags --name $acrName --repository $imageTag --output table

```

## Tutorial: Deploy a container application to Azure Container Instances

```powershell
# Get the full login server name for your Azure container registry. 
$myResourceGroup = "fnodeappincontainerResourceGroup"
$acrName = "fnodeappincontainerContainerRegistry"
$imageTag = "fredericaltorres/fnodeappincontainer"
az acr show --name $acrName --query loginServer --output table
$acrLoginServer = "fnodeappincontainercontainerregistry.azurecr.io"
$newTag = "$acrLoginServer/$imageTag`:v1"
$azureLoginName = "fredericaltorres@live.com"
$azurePassword = "6zdT3g6zdT3g!"
$dnsLabel="fnodeappincontainerdns"

az container create --resource-group $myResourceGroup --name $imageTag --image $newTag --cpu 1 --memory 1 --registry-login-server $acrLoginServer --registry-username $azureLoginName --registry-password $azurePassword --dns-name-label $dnsLabel --ports 80
```