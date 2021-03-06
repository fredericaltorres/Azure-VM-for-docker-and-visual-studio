﻿
Import-Module ".\Util.psm1"

# https://xainey.github.io/2016/powershell-classes-and-concepts/

class KubernetesManager {

    [string] $ClusterName

    KubernetesManager([string]$acrName, [string]$acrLoginServer, [string]$azureContainerRegistryPassword, [bool]$firstInitialization) {
   
        #$this.trace("Retreiving clusters information...", DarkYellow)

        $ks = $this.getAllClusterInfo()
        $k = $ks[0]
        $this.ClusterName = $k.name
        
        $this.trace("Kubernetes cluster name: $($this.ClusterName), $($k.agentPoolProfiles.count) agents, os: $($k.agentPoolProfiles.osType)")
        $this.trace("                   version: $($k.kubernetesVersion), fqdn: $($k.fqdn)")
        

        $this.trace("Initializing Kubernetes Cluster:$($this.ClusterName), Azure Container Registry:$acrName")

        if($firstInitialization) {
            az aks get-credentials --resource-group $this.ClusterName --name $this.ClusterName --overwrite-existing # Switch to 
        }

        kubectl config use-context $this.ClusterName # Switch to cluster

        if($firstInitialization) {

            # Define the Azure Container Registry as a docker secret
            kubectl create secret docker-registry ($acrName.ToLowerInvariant()) --docker-server $acrLoginServer --docker-email fredericaltorres@gmail.com --docker-username=$acrName --docker-password $azureContainerRegistryPassword
        }

        $this.trace("")
    }

    [void] trace([string]$message, [string]$color) {

        Write-HostColor $message $color
    }


    [void] trace([string]$message) {

        Write-HostColor $message Cyan
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

    [object] apply([string]$fileName, [bool]$record) {

        $jsonParsed = $null
        if($record) {

            $jsonParsed = JsonParse( kubectl apply -f $fileName --record -o json )
        }
        else {

            $jsonParsed = JsonParse( kubectl apply -f $fileName  -o json )
        }    
        return $jsonParsed
    }

    [object] getDeployment([string]$deploymentName) {

        return JsonParse( kubectl get deployment $deploymentName --output json )
    }

    [void] waitForDeployment([string]$deploymentName) {
    
        retry "Waiting for deployment: $deploymentName" {

            $deploymentInfo = $this.getDeployment($deploymentName)
            return ( $deploymentInfo.status.readyReplicas -eq $deploymentInfo.status.replicas )
        }
    }

    [string] getForDeploymentInformation([string]$deploymentName) {
    
        $deploymentInfo = $this.getDeployment($deploymentName)
        $labels = $deploymentInfo.metadata.labels
        $r = "Deployment: $deploymentName`r`n            replicas:$($deploymentInfo.status.replicas), readyReplicas:$($deploymentInfo.status.readyReplicas), availableReplicas:$($deploymentInfo.status.availableReplicas), updatedReplicas:$($deploymentInfo.status.updatedReplicas)"
        $r += "                                 labels: $($labels)"
        $labels
        return $r
    }

    [object] getService([string]$serviceName) {

        return JsonParse( kubectl get service $serviceName --output json )
    }

    [void] waitForService([string]$serviceName) {
    
        retry "Waiting for service: $serviceName" {

            $serviceInfo = $this.getService($serviceName)
            return ( $serviceInfo.status.loadBalancer.ingress -ne $null )
        }
    }


    [string] getForServiceInformation([string]$serviceName) {
    
        $serviceInfo = $this.getService($serviceName)

        # Retreive ip + port and verify home url
        $loadBlancerIp = $this.GetServiceLoadBalancerIP($serviceName)
        $loadBlancerPort = $this.GetServiceLoadBalancerPort($serviceName)
        $labels = $serviceInfo.metadata.labels

        $r = "Service: $serviceName`r`n         type: $($serviceInfo.spec.type), url: http://$loadBlancerIp`:$loadBlancerPort, labels: $($labels)"
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

        $this.trace("Create deployment $fileName")
        $jsonParsed = $this.create($fileName, $true)

        $this.trace("Deployment name:$($jsonParsed.metadata.name)")
        return $jsonParsed.metadata.name
    }

    [object] createService([string]$fileName) {

        $this.trace("Create service $fileName")
        $jsonParsed = $this.create($fileName, $true)
        $this.trace("Service name:$($jsonParsed.metadata.name)")
        return $jsonParsed.metadata.name
    }

    [object] applyService([string]$fileName) {

        $this.trace("Apply service $fileName")
        $jsonParsed = $this.apply($fileName, $true)
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
function GetKubernetesManagerInstance([string]$acrName, [string]$acrLoginServer, [string]$azureContainerRegistryPassword, [bool]$firstInitialization) {

    return New-Object KubernetesManager -ArgumentList $acrName, $acrLoginServer, $azureContainerRegistryPassword, $firstInitialization
}

Export-ModuleMember -Function GetKubernetesManagerInstance
