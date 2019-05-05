[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$action = "instantiate", # build, push, instantiate
    [Parameter(Mandatory=$false)]
    [string]$imageTag = "fredericaltorres/fnodeappincontainer",
    [Parameter(Mandatory=$false)]
    [string]$containerVersionTag = "v3",
    [Parameter(Mandatory=$false)]
    [string]$containerSourceCode = "C:\\dvt\\docker\\Azure-VM-for-docker-and-visual-studio\\fNodeAppInContainer",
    [Parameter(Mandatory=$false)]
    $containeInstanceName = "fnodeappincontainerinstance",

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

function GetContainerInstanceIpFromJsonMetadata($jsonContent) {

    $fqdn = $jsonContent.ipAddress.fqdn
    $ip = $jsonContent.ipAddress.ip
    $port = $jsonContent.ipAddress.ports.port
    $url = "http://$fqdn`:8080"
    write-host "url:$url"
    return $url    
}

cls
Write-Host "deployContainerToAzureContainerRegistry"
cd $containerSourceCode

$newTag = "$acrLoginServer/$imageTag`:$containerVersionTag"

switch($action) {

    build { 
        Write-Host "Build imageTag:$imageTag"
        docker build -t $imageTag .
    }
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
    instantiate {
        $containeInstanceName = $containeInstanceName.toLower()
        $azureLoginName = $acrName
        $azurePassword = ""
        $dnsLabel="$($containeInstanceName)dns"

        write-host "About to instantiate instance of container $containeInstanceName from image $imageTag"
        write-host "cmd: az container create --ports $containerInstancePort --os-type Linux  --name $containeInstanceName --image $newTag --cpu $containerInstanceCpu --memory $containerInstanceMemory --registry-login-server $acrLoginServer --registry-username $azureLoginName --registry-password '$azurePassword' --dns-name-label $dnsLabel --resource-group $myResourceGroup"

        $jsonString = az container create --ports $containerInstancePort --os-type Linux  --name $containeInstanceName --image $newTag --cpu $containerInstanceCpu --memory $containerInstanceMemory --registry-login-server $acrLoginServer --registry-username $azureLoginName --registry-password '$azurePassword' --dns-name-label $dnsLabel --resource-group $myResourceGroup

        $jsonContent = $jsonString | ConvertFrom-Json;
        $url = GetContainerInstanceIpFromJsonMetadata $jsonContent
        $apiCallResult = Invoke-RestMethod -Method Get -Uri $url
        "Api returned $apiCallResult"
        
    }
}

