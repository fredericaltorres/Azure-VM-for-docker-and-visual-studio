[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$action = "initialDeploymentBlue", # getInfo, initialDeploymentBlue, deleteInitialDeploymentBlue, DeploymentGreen

     # Fred Azure Container Registry Information
    [Parameter(Mandatory=$false)]
    [string]$acrName = "FredContainerRegistry", # Consider that the Azure Container `FredContainerRegistry` already exist
    [Parameter(Mandatory=$false)]
    [string]$myResourceGroup = "FredContainerRegistryResourceGroup",
    [Parameter(Mandatory=$false)] # The full login server name for your Azure container registry.  az acr show --name $acrName --query loginServer --output table
    [string]$acrLoginServer = "fredcontainerregistry.azurecr.io",

    [Parameter(Mandatory=$false)] # The Azure Container Registry has default username which is the name of the registry, but there is a password required when pushing a image
    [string]$azureContainerRegistryPassword = "",
	
    [Parameter(Mandatory=$false)] 
    [bool]$clearScreen = $true
)

# https://docs.microsoft.com/en-us/azure/container-registry/container-registry-auth-aks
#az acr show --name $acrName --resource-group $myResourceGroup --query "id" --output tsv
#az acr show --name $acrName --query loginServer --output tsv

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

$context = @{
    ENVIRONMENT = "prod";
    APP_VERSION = "1.0.2"
}


# For now pick the first cluster available
$kubernetesManager = GetKubernetesManagerInstance $acrName $acrLoginServer $azureContainerRegistryPassword


switch($action) {

    initialDeploymentBlue { 

        Write-Host-Color "*** Deploy initial Blue version v1.0.2 ***" Blue

        $context = @{ ENVIRONMENT = "prod"; APP_VERSION = "1.0.2" }

        $processedFile = processFile $context "Deployment.{Params}.yaml"
        $deploymentName = $kubernetesManager.createDeployment($processedFile)
        $kubernetesManager.waitForDeployment($deploymentName)

        #$deploymentName = $kubernetesManager.createDeployment("Deployment.Create.v1.0.2.yaml")
        #$kubernetesManager.waitForDeployment($deploymentName)

        $processedFile = processFile $context "Service.{Params}.yaml"
        $serviceName = $kubernetesManager.createService($processedFile)
        $kubernetesManager.waitForService($serviceName)

        #$serviceName = $kubernetesManager.createService("Service.v1.0.2.yaml")
        #$kubernetesManager.waitForService($serviceName)
        
        $loadBlancerIp = $kubernetesManager.GetServiceLoadBalancerIP($serviceName)
        $loadBlancerPort = $kubernetesManager.GetServiceLoadBalancerPort($serviceName)
        Write-Host-Color "LoadBalancer Ip:$($loadBlancerIp), port:$($loadBlancerPort)" DarkYellow
        urlMustReturnHtml "http://$loadBlancerIp`:$loadBlancerPort"
    }

    DeploymentGreen { 

        Write-Host-Color "*** Deploy Green v1.0.3 ***" Green
        
        #$deploymentName = $kubernetesManager.createDeployment("Deployment.Create.v1.0.3.yaml")
        #$kubernetesManager.waitForDeployment($deploymentName)

        $serviceName = $kubernetesManager.createService("Service.v1.0.3.yaml")
        $kubernetesManager.waitForService($serviceName)
        
        $loadBlancerIp = $kubernetesManager.GetServiceLoadBalancerIP($serviceName)
        $loadBlancerPort = $kubernetesManager.GetServiceLoadBalancerPort($serviceName)
        Write-Host-Color "LoadBalancer Ip:$($loadBlancerIp), port:$($loadBlancerPort)" DarkYellow
        urlMustReturnHtml "http://$loadBlancerIp`:$loadBlancerPort"
    }

    getInfo {

        $deploymentName = "fdotnetcorewebapp-deployment-1.0.2"
        Write-Host-Color $kubernetesManager.getForDeploymentInformation($deploymentName)

        $serviceName = "fdotnetcorewebapp-service"
        Write-Host-Color $kubernetesManager.getForServiceInformation($serviceName)
    }

    deleteInitialDeploymentBlue {
        
        $deploymentName = "fdotnetcorewebapp-deployment-1.0.2"
        $kubernetesManager.deleteDeployment($deploymentName)

        $serviceName = "fdotnetcorewebapp-service"
        $kubernetesManager.deleteService($serviceName)
    }
}

Write-Host "Done" -ForegroundColor DarkYellow
