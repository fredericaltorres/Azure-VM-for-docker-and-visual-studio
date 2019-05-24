﻿
Import-Module ".\Util.psm1"

# https://xainey.github.io/2016/powershell-classes-and-concepts/

class KubernetesManager {

    [string] $ClusterName

    KubernetesManager($acrName, $acrLoginServer, $azureContainerRegistryPassword) {
   
        #$this.trace("Retreiving clusters information...", DarkYellow)

        $ks = $this.getAllClusterInfo()
        $k = $ks[0]
        $this.ClusterName = $k.name
        $this.trace("Kubernetes Cluster name:$($this.ClusterName), $($k.agentPoolProfiles.count) agents, os:$($k.agentPoolProfiles.osType)")

        $this.trace("Initializing Kubernetes Cluster:$($this.ClusterName), Azure Container Registry:$acrName")

        az aks get-credentials --resource-group $this.ClusterName --name $this.ClusterName --overwrite-existing # Switch to 
        kubectl config use-context $this.ClusterName # Switch to cluster

        # Define the Azure Container Registry as a docker secret
        kubectl create secret docker-registry ($acrName.ToLowerInvariant()) --docker-server $acrLoginServer --docker-email fredericaltorres@gmail.com --docker-username=$acrName --docker-password $azureContainerRegistryPassword
    }

    [void] trace([string]$message, [string]$color) {

        Write-Host-Color $message $color
    }


    [void] trace([string]$message) {

        Write-Host-Color $message Cyan
        # $this.trace("",Cyan)
    }
   
    [object] create([string]$fileName, [bool]$record) {

        $jsonParsed = $null
        if($record) {
            $jsonParsed = JsonParse( kubectl create -f $fileName --record -o json )
        }
        else {
            $jsonParsed = JsonParse( kubectl create -f $fileName  -o json )
        }    
        return $jsonParsed
    }

    [object] getDeployment([string]$deploymentName) {

        return JsonParse( kubectl get deployment $deploymentName --output json )
    }

    [void] waitForDeployment([string]$deploymentName) {
    
        retry "Waiting for deployment:$deploymentName" {

            $deploymentInfo = $this.getDeployment($deploymentName)
            return ( $deploymentInfo.status.readyReplicas -eq $deploymentInfo.status.replicas )
        }
    }

    [string] getForDeploymentInformation([string]$deploymentName) {
    
        $deploymentInfo = $this.getDeployment($deploymentName)
        $r = "Deployment: $deploymentName`r`n            replicas:$($deploymentInfo.status.replicas), readyReplicas:$($deploymentInfo.status.readyReplicas), availableReplicas:$($deploymentInfo.status.availableReplicas), updatedReplicas:$($deploymentInfo.status.updatedReplicas)"
        return $r
    }

    [object] getService([string]$serviceName) {

        return JsonParse( kubectl get service $serviceName --output json )
    }

    [void] waitForService([string]$serviceName) {
    
        retry "Waiting for service:$serviceName" {

            $serviceInfo = $this.getService($serviceName)
            return ( $serviceInfo.status.loadBalancer.ingress -ne $null )
        }
    }


    [string] getForServiceInformation([string]$serviceName) {
    
        $serviceInfo = $this.getService($serviceName)
        $r = "Service: $serviceName`r`n         type:$($serviceInfo.spec.type)"
        return $r
    }

    [string] GetServiceLoadBalancerIP([string]$serviceName) {
    
        $serviceInfo = $this.getService($serviceName)

        if( $serviceInfo.status.loadBalancer.ingress -ne $null ) {

            if( $serviceInfo.status.loadBalancer.ingress.length -gt 0 ) {

                return $serviceInfo.status.loadBalancer.ingress[0].ip
            }
        }
        return $null
    }

    [string] GetServiceLoadBalancerPort([string]$serviceName) {
    
        $serviceInfo = $this.getService($serviceName)

        if( $serviceInfo.spec.ports -ne $null -and $serviceInfo.spec.ports.length -gt 0 ) {

            if( $serviceInfo.spec.ports[0].port -ne $null ) {

                return $serviceInfo.spec.ports[0].port
            }
        }
        return $null
    }

    [object] createDeployment([string]$fileName) {

        $this.trace("Deployment $fileName")
        $jsonParsed = $this.create($fileName, $true)

        $this.trace("Deployment name:$($jsonParsed.metadata.name)")
        return $jsonParsed.metadata.name
    }

    [object] createService([string]$fileName) {

        $this.trace("Service $fileName")
        $jsonParsed = $this.create($fileName, $true)
        $this.trace("Service name:$($jsonParsed.metadata.name)")
        return $jsonParsed.metadata.name
    }

    [void] deleteService([string]$fileName) {

        $this.trace("Delete Service $fileName")
        kubectl delete service $fileName
    }

    [void] deleteDeployment([string]$fileName) {

        $this.trace("Delete Deployment $fileName")
        kubectl delete deployment $fileName
    }

    [object] getAllClusterInfo() {

        return JsonParse ( az aks list -o json )
    }
}


# https://arcanecode.com/2016/04/05/accessing-a-powershell-class-defined-in-a-module-from-outside-a-module/
function GetKubernetesManagerInstance($acrName, $acrLoginServer, $azureContainerRegistryPassword) {

    return New-Object KubernetesManager -ArgumentList $acrName, $acrLoginServer, $azureContainerRegistryPassword    
}

Export-ModuleMember -Function GetKubernetesManagerInstance