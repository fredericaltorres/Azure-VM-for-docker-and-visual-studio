﻿[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$action = "initialDeployment", # build, push, instantiate, deleteInstance    


     # Fred Azure Container Registry Information
    [Parameter(Mandatory=$false)]
    [string]$acrName = "FredContainerRegistry", # Consider that the Azure Container `FredContainerRegistry` already exist
    [Parameter(Mandatory=$false)]
    [string]$myResourceGroup = "FredContainerRegistryResourceGroup",
    [Parameter(Mandatory=$false)] # The full login server name for your Azure container registry.  az acr show --name $acrName --query loginServer --output table
    [string]$acrLoginServer = "fredcontainerregistry.azurecr.io",

    [Parameter(Mandatory=$false)] # The Azure Container Registry has default username which is the name of the registry, but there is a password required when pushing a image
    [string]$azureContainerRegistryPassword = "izBEjx",


    [Parameter(Mandatory=$false)] 
    [bool]$clearScreen = $true
)


function Write-Host-Color([string]$message, $color = "Cyan") {

    Write-Host ""
    Write-Host $message -ForegroundColor $color

}

function JsonParse([string]$json) {

    [array]$jsonContent = $json | ConvertFrom-Json
    return ,$jsonContent
}

# Execute the block of code 60 times and wait 6 seconds in between each try
# If the block fail 60 time we will have to wait 6 minutes
# We have a 6 minutes time out by default
function retry([string]$message, [ScriptBlock] $block, [int]$wait = 6, [int]$maxTry = 60) { 

    $try = 0

    while($true) {

        Write-Host "[$try]$message" -ForegroundColor Cyan

        try {

            $ok = & $block
            if($ok) {

                Write-Host "[PASSED]$message" -ForegroundColor Green
                return $true
            }
            Start-Sleep -s $wait
            $try += 1
            if($try -eq $maxTry) {
                Write-Error "[FAILED]Timeout: $message"
                break # Fail time out
            }
        }
        catch {            

            $ErrorMessage = $_.Exception.Message
            $FailedItem = $_.Exception.ItemName
            Write-Error $ErrorMessage
            break
        }
    }
    return $false
}

function kubernetes_create([string]$fileName, [int]$waitAfter = 0, [bool]$record = $false) {

    $jsonParsed = $null
    if($record) {
        $jsonParsed = JsonParse( kubectl create -f $fileName --record -o json )
    }
    else {
        $jsonParsed = JsonParse( kubectl create -f $fileName  -o json )
    }    
    if($waitAfter -gt 0) {
        Start-Sleep -s $waitAfter
    }
    return $jsonParsed
}

function kubernetes_getDeployment([string]$deploymentName) {

    return JsonParse( kubectl get deployment $deploymentName --output json )
}


function kubernetes_waitForDeployment([string]$deploymentName, [int]$wait = 3) {
    
    retry "Waiting for deployment:$deploymentName" {

        $deploymentInfo = kubernetes_getDeployment $deploymentName
        return ( $deploymentInfo.status.readyReplicas -eq $deploymentInfo.status.replicas )
    }
}

function kubernetes_getService([string]$serviceName) {

    return JsonParse( kubectl get service $serviceName --output json )
}

function kubernetes_waitForService([string]$serviceName, [int]$wait = 3) {
    
    retry "Waiting for service:$serviceName" {

        $serviceInfo = kubernetes_getService $serviceName
        return ( $serviceInfo.status.loadBalancer.ingress -ne $null )
    }
}

function kubernetes_GetServiceLoadBalancerIP([string]$serviceName) {
    
    $serviceInfo = kubernetes_getService $serviceName

    if( $serviceInfo.status.loadBalancer.ingress -ne $null ) {

        if( $serviceInfo.status.loadBalancer.ingress.length -gt 0 ) {

            return $serviceInfo.status.loadBalancer.ingress[0].ip
        }
    }
    return $null
}

function kubernetes_createDeployment([string]$fileName, [int]$waitAfter = 0, [bool]$record = $false) {

    Write-Host-Color "Deployment $fileName"
    $jsonParsed = kubernetes_create $fileName $waitAfter $record
    Write-Host-Color "Service name:$($jsonParsed.metadata.name)"
    return $jsonParsed.metadata.name
}

function kubernetes_createService([string]$fileName, [int]$waitAfter = 0, [bool]$record = $false) {

    Write-Host-Color "Service $fileName"
    $jsonParsed = kubernetes_create $fileName $waitAfter $record
    Write-Host-Color "Service name:$($jsonParsed.metadata.name)"
    return $jsonParsed.metadata.name
}


function kubernetes_getAllClusterInfo() {

    return JsonParse ( az aks list -o json )
}

function kubernetes_init($kubernetesInstanceName) {

    az aks get-credentials --resource-group $kubernetesInstanceName --name $kubernetesInstanceName # Switch to 
    kubectl config use-context $kubernetesInstanceName # Switch to cluster

    # Define the Azure Container Registry as a docker secret
    kubectl create secret docker-registry ($acrName.ToLowerInvariant()) --docker-server $acrLoginServer --docker-email fredericaltorres@gmail.com --docker-username=$acrName --docker-password $azureContainerRegistryPassword
}

if($clearScreen) {
    cls
}
else {
    Write-Host "" 
}

Write-Host "BlueGreenDeployment.Kubernetes -Action:$action" -ForegroundColor Yellow
Write-Host " ... " -ForegroundColor DarkYellow

switch($action) {

    initialDeployment { 
        
        Write-Host-Color "Deploy initial deployment"

        $ks = kubernetes_getAllClusterInfo
        $k = $ks[0]
        $kubernetesInstanceName = $k.name
        Write-Host-Color "Kubernetes Cluster name:$($kubernetesInstanceName), $($k.agentPoolProfiles.count) agents, os:$($k.agentPoolProfiles.osType)"

        kubernetes_init $kubernetesInstanceName
        $deploymentName = kubernetes_createDeployment "Deployment.Create.v1.0.2.yaml"
        kubernetes_waitForDeployment $deploymentName

        $serviceName = kubernetes_createService "Service.v1.0.2.yaml"
        kubernetes_waitForService $serviceName

        $serviceName = "fdotnetcorewebapp-service"
        $loadBlancerIp = kubernetes_GetServiceLoadBalancerIP $serviceName

        Write-Host "LoadBalancer Ip:$($loadBlancerIp)" -ForegroundColor DarkYellow
    }
}

Write-Host "Done" -ForegroundColor DarkYellow
