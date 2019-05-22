[CmdletBinding()]
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
    [string]$azureContainerRegistryPassword = "PASSWORD",


    [Parameter(Mandatory=$false)] 
    [bool]$clearScreen = $true
)

Import-Module ".\Util.psm1" -Force
Import-Module ".\KubernetesManager.psm1" -Force


if($clearScreen) {
    cls
}
else {
    Write-Host "" 
}

Write-Host-Color "BlueGreenDeployment.Kubernetes -Action:$action" Yellow
Write-Host-Color "... " DarkYellow

# For now pick the first cluster available
$kubernetesManager = GetKubernetesManagerInstance $acrName $acrLoginServer $azureContainerRegistryPassword


switch($action) {

    initialDeployment { 
        
        Write-Host-Color "*** Deploy initial deployment ***"
        
        $deploymentName = $kubernetesManager.createDeployment("Deployment.Create.v1.0.2.yaml")
        $kubernetesManager.waitForDeployment($deploymentName)

        $serviceName = $kubernetesManager.createService("Service.v1.0.2.yaml")
        $kubernetesManager.waitForService($serviceName)

        
        $loadBlancerIp = $kubernetesManager.GetServiceLoadBalancerIP($serviceName)

        Write-Host-Color "LoadBalancer Ip:$($loadBlancerIp)" DarkYellow
    }
    deleteInitialDeployment {
        
        $deploymentName = "fdotnetcorewebapp-deployment-1.0.2"
        $kubernetesManager.deleteDeployment($deploymentName)

        $serviceName = "fdotnetcorewebapp-service"
        $kubernetesManager.deleteService($serviceName)
    }
}

Write-Host "Done" -ForegroundColor DarkYellow
