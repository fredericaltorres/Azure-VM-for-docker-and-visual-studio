# Fred Node App In Container

## How to build the container

```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker build -t $imageTag .
# v1 - 335ee5d7fd6d
# v2 - 108e34bf4435 
docker images $imageTag
```

## How to run the image

```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker run -p 49160:8080 -d $imageTag
62c7c40a511abef37735709400fafd414c6e5561d57897046b17eec067bf5d40

docker ps # Get container ID

docker logs 62c7c40a511abef37735709400fafd414c6e5561d57897046b17eec067bf5d40    # Print app output
docker exec -it 62c7c40a511abef37735709400fafd414c6e5561d57897046b17eec067bf5d40 /bin/bash # Enter the container
```

## how to test the container image locally
To test your app, get the port of your app that Docker mapped:

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
docker stop 62c7c40a511abef37735709400fafd414c6e5561d57897046b17eec067bf5d40
```

## How to deploy the container in the cloud
Let's consider that the Azure Container Registry `FredContainerRegistry` already exist.

- [Install Install the Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
- [Tutorial: Deploy an Azure container registry and push a container image](https://docs.microsoft.com/en-us/azure/container-instances/container-instances-tutorial-prepare-acr)
- [Azure container registry pricing](https://azure.microsoft.com/en-us/pricing/details/container-registry/)


```powershell
az login # if you never logged in

$imageTag = "fredericaltorres/fnodeappincontainer"
# Consider that the Azure Container `FredContainerRegistry` already exist
$acrName = "FredContainerRegistry"
$myResourceGroup = "FredContainerRegistryResourceGroup"
az acr login --name $acrName # Log in to container registry
# Get the full login server name for your Azure container registry. 
# az acr show --name $acrName --query loginServer --output table
$acrLoginServer = "fredcontainerregistry.azurecr.io"
# Tag image with the loginServer of your container registry. 
$newVersionTag = "v2"
$newTag = "$acrLoginServer/$imageTag`:$newVersionTag"

docker tag $imageTag $newTag 
docker images
# Push tagged image to registry
docker push $newTag

# List images in Azure Container Registry
az acr repository list --name $acrName --output table

# To see the tags version for a specific image, 
az acr repository show-tags --name $acrName --repository $imageTag --output table

```

## Tutorial: Deploy a container application to Azure Container Instances

```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
# Consider that the Azure Container `FredContainerRegistry` already exist
$acrName = "FredContainerRegistry"
$myResourceGroup = "FredContainerRegistryResourceGroup"
#az acr login --name $acrName # Log in to container registry
# Get the full login server name for your Azure container registry. 
# az acr show --name $acrName --query loginServer --output table
$acrLoginServer = "fredcontainerregistry.azurecr.io"
# Tag image with the loginServer of your container registry. 
$newVersionTag = "v3"
$newTag = "$acrLoginServer/$imageTag`:$newVersionTag"
$azureLoginName = $acrName
$azurePassword = "/HMiRc"
$containeInstanceName = "$($imageTag)Instance".replace("fredericaltorres/","").ToLower()
$dnsLabel="$($containeInstanceName)dns"

# az container xxxxx -> https://docs.microsoft.com/en-us/cli/azure/container?view=azure-cli-latest#az-container-delete

$jsonString = az container create --resource-group $myResourceGroup --name $containeInstanceName --image $newTag --cpu 1 --memory 1 --registry-login-server $acrLoginServer --registry-username $azureLoginName --registry-password $azurePassword  --ports 8080 --os-type Linux --dns-name-label $dnsLabel

$jsonContent = $jsonString | ConvertFrom-Json;
$fqdn = $jsonContent.ipAddress.fqdn
$ip = $jsonContent.ipAddress.ip
$port = $jsonContent.ipAddress.ports.port
$url = "http://$fqdn`:8080"
write-host "url:$url"
$apiCallResult = Invoke-RestMethod -Method Get -Uri $url
"Api returned $apiCallResult"

az container stop --resource-group $myResourceGroup --name $containeInstanceName
az container delete --resource-group $myResourceGroup --name $containeInstanceName --yes
az container start --resource-group $myResourceGroup --name $containeInstanceName

$jsonString = az container list --resource-group $myResourceGroup
$jsonString = az container show --resource-group $myResourceGroup --name $containeInstanceName
az container logs --resource-group $myResourceGroup --name $containeInstanceName
az container exec --resource-group $myResourceGroup --name $containeInstanceName --exec-command "/bin/bash"

```

<#

  {list,create,show,delete,logs,exec,export,attach,restart,stop,start}

usage: az container create [-h] [--verbose] [--debug]
                           [--output {json,jsonc,table,tsv,yaml,none}]
                           [--query JMESPATH] --resource-group
                           RESOURCE_GROUP_NAME [--name NAME] [--image IMAGE]
                           [--location LOCATION] [--cpu CPU] [--memory MEMORY]
                           [--restart-policy {Always,OnFailure,Never}]
                           [--ports PORTS [PORTS ...]] [--protocol {TCP,UDP}]
                           [--os-type {Windows,Linux}]
                           [--ip-address {Public,Private}]
                           [--dns-name-label DNS_NAME_LABEL]
                           [--command-line COMMAND_LINE]
                           [--environment-variables ENVIRONMENT_VARIABLES [ENVIRONMENT_VARIABLES ...]]
                           [--secure-environment-variables SECURE_ENVIRONMENT_VARIABLES [SECURE_ENVIRONMENT_VARIABLES ...]]
                           [--registry-login-server REGISTRY_LOGIN_SERVER]
                           [--registry-username REGISTRY_USERNAME]
                           [--registry-password REGISTRY_PASSWORD]
                           [--azure-file-volume-share-name AZURE_FILE_VOLUME_SHARE_NAME]
                           [--azure-file-volume-account-name AZURE_FILE_VOLUME_ACCOUNT_NAME]
                           [--azure-file-volume-account-key AZURE_FILE_VOLUME_ACCOUNT_KEY]
                           [--azure-file-volume-mount-path AZURE_FILE_VOLUME_MOUNT_PATH]
                           [--log-analytics-workspace LOG_ANALYTICS_WORKSPACE]
                           [--log-analytics-workspace-key LOG_ANALYTICS_WORKSPACE_KEY]
                           [--vnet VNET] [--vnet-name VNET_NAME]
                           [--vnet-address-prefix VNET_ADDRESS_PREFIX]
                           [--subnet SUBNET]
                           [--subnet-address-prefix SUBNET_ADDRESS_PREFIX]
                           [--network-profile NETWORK_PROFILE]
                           [--gitrepo-url GITREPO_URL]
                           [--gitrepo-dir GITREPO_DIR]
                           [--gitrepo-revision GITREPO_REVISION]
                           [--gitrepo-mount-path GITREPO_MOUNT_PATH]
                           [--secrets SECRETS [SECRETS ...]]
                           [--secrets-mount-path SECRETS_MOUNT_PATH]
                           [--file FILE]
                           [--assign-identity [ASSIGN_IDENTITY [ASSIGN_IDENTITY ...]]]
                           [--scope IDENTITY_SCOPE] [--role IDENTITY_ROLE]
                           [--no-wait] [--subscription _SUBSCRIPTION]
#>


az container show --resource-group $myResourceGroup --name $imageTag --query instanceView.state

```
