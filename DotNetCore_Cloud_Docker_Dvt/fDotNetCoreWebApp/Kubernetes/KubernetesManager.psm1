
Import-Module ".\Util.psm1"

# https://xainey.github.io/2016/powershell-classes-and-concepts/

class KubernetesManager {

    [string] $ClusterName

    KubernetesManager($acrName, $acrLoginServer, $azureContainerRegistryPassword) {
   
        Write-Host-Color "Retreiving clusters information..." DarkYellow

        $ks = $this.getAllClusterInfo()
        $k = $ks[0]
        $this.ClusterName = $k.name
        Write-Host-Color "Kubernetes Cluster name:$($this.ClusterName), $($k.agentPoolProfiles.count) agents, os:$($k.agentPoolProfiles.osType)"

        Write-Host-Color "Initializing Kubernetes Cluster:$this.ClusterName, Azure Container Registry:$acrName"

        az aks get-credentials --resource-group $this.ClusterName --name $this.ClusterName # Switch to 
        kubectl config use-context $this.ClusterName # Switch to cluster

        # Define the Azure Container Registry as a docker secret
        kubectl create secret docker-registry ($acrName.ToLowerInvariant()) --docker-server $acrLoginServer --docker-email fredericaltorres@gmail.com --docker-username=$acrName --docker-password $azureContainerRegistryPassword
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

    waitForDeployment([string]$deploymentName) {
    
        retry "Waiting for deployment:$deploymentName" {

            $deploymentInfo = $this.getDeployment($deploymentName)
            return ( $deploymentInfo.status.readyReplicas -eq $deploymentInfo.status.replicas )
        }
    }

    [object] getService([string]$serviceName) {

        return JsonParse( kubectl get service $serviceName --output json )
    }

    waitForService([string]$serviceName) {
    
        retry "Waiting for service:$serviceName" {

            $serviceInfo = $this.getService($serviceName)
            return ( $serviceInfo.status.loadBalancer.ingress -ne $null )
        }
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

    [object] createDeployment([string]$fileName) {

        Write-Host-Color "Deployment $fileName"
        $jsonParsed = $this.create($fileName, $true)
        Write-Host-Color "Deployment name:$($jsonParsed.metadata.name)"
        return $jsonParsed.metadata.name
    }

    [object] createService([string]$fileName) {

        Write-Host-Color "Service $fileName"
        $jsonParsed = $this.create($fileName, $true)
        Write-Host-Color "Service name:$($jsonParsed.metadata.name)"
        return $jsonParsed.metadata.name
    }

    deleteService([string]$fileName) {

        Write-Host-Color "Delete Service $fileName"
        kubectl delete service $fileName
    }

    deleteDeployment([string]$fileName) {

        Write-Host-Color "Delete Deployment $fileName"
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
