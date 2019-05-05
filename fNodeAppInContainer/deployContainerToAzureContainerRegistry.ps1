[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$action = "deleteInstantiate", # build, push, instantiate, deleteInstantiate
    [Parameter(Mandatory=$false)]
    [string]$imageTag = "fredericaltorres/fnodeappincontainer",
    [Parameter(Mandatory=$false)]
    [string]$containerVersionTag = "v3",
    [Parameter(Mandatory=$false)]
    $containeInstanceName = "fnodeappincontainerinstance0",

    # Fred Azure Container Registry Information
    [Parameter(Mandatory=$false)]
    [string]$acrName = "FredContainerRegistry", # Consider that the Azure Container `FredContainerRegistry` already exist
    [Parameter(Mandatory=$false)]
    [string]$myResourceGroup = "FredContainerRegistryResourceGroup",
    [Parameter(Mandatory=$false)] # The full login server name for your Azure container registry.  az acr show --name $acrName --query loginServer --output table
    [string]$acrLoginServer = "fredcontainerregistry.azurecr.io",

    [Parameter(Mandatory=$false)] 
    [int]$containerInstanceCpu = 1,
    [Parameter(Mandatory=$false)] 
    [int]$containerInstanceMemory = 1,
    [Parameter(Mandatory=$false)] 
    [int]$containerInstancePort = 8080



    #[Parameter(Mandatory=$false, Position=1)]
    #[string]$object       = "",
    #[Parameter(Mandatory=$false, Position=2)]
    #[string]$objectName   = "",
    #[Parameter(Mandatory=$false, Position=3)]
    #[string]$objectName2  = "",
    #[Parameter(Mandatory=$false, Position=4)]
    #[Alias('m')]
    #[string]$message = ""
)

function GetContainerInstanceIpFromJsonMetadata($jsonString) {

    $jsonContent = $jsonString | ConvertFrom-Json
    $fqdn = $jsonContent.ipAddress.fqdn
    $ip = $jsonContent.ipAddress.ip
    $port = $jsonContent.ipAddress.ports.port
    $url = "http://$fqdn`:8080"
    return $url
}

cls
Write-Host "deployContainerToAzureContainerRegistry"
$newTag = "$acrLoginServer/$imageTag`:$containerVersionTag"
$containeInstanceName = $containeInstanceName.toLower()

switch($action) {

    # Build and publish the current container source code in the local docker image repository
    build { 
        Write-Host "Build imageTag:$imageTag"
        docker build -t $imageTag .
    }
    # Tag the last image built of the container in the the local docker image repository and push into the Azure Container Registry
    push {
        write-host "Login to azure registry $acrName"
        az acr login --name $acrName # Log in to container registry

        # Tag image with the loginServer of your container registry. 
        write-host "About to tag container $imageTag with tag:$newTag"
        docker tag $imageTag $newTag 
        docker images
        write-host "About to push container $imageTag tagged $newTag to azure registry $acrName"
        docker push $newTag # Push tagged image from docker into the azure registry logged in

        write-host "All version in azure registry for container $imageTag"
        az acr repository show-tags --name $acrName --repository $imageTag --output table
    }
    # Using the versioned image in the Azure Container Registry, instanciate an instance of the container under a specific name
    instantiate {
        
        $azureLoginName = $acrName
        $azurePassword = "/HMiRc"
        $dnsLabel="$($containeInstanceName)dns"

        write-host "About to instantiate instance of container $containeInstanceName from image $imageTag"

        $jsonString = az container create --resource-group $myResourceGroup --name $containeInstanceName --image $newTag --cpu $containerInstanceCpu --memory $containerInstanceMemory  --registry-login-server $acrLoginServer --registry-username $azureLoginName --registry-password $azurePassword  --ports $containerInstancePort --os-type Linux --dns-name-label $dnsLabel

        
        $url = GetContainerInstanceIpFromJsonMetadata $jsonString
        Write-Host "Container Instance URL:$url"
        $apiCallResult = Invoke-RestMethod -Method Get -Uri $url
        "Api returned $apiCallResult"        
    }
    # Stop and delete an instance of the container under a specific name and version
    deleteInstantiate {
        write-host "About to stop container instance $containeInstanceName"
        az container stop --resource-group $myResourceGroup --name $containeInstanceName
        write-host "About to delete container instance $containeInstanceName"
        az container delete --resource-group $myResourceGroup --name $containeInstanceName --yes
    }
}

