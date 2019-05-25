[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
    [string]$action = "demo" # demo, deleteDeployments
)

Import-Module ".\Util.psm1" -Force

cls

Write-HostColor "Blue Green Deployment With Kubernetes, Azure CLI, Powershell Demo" Yellow

switch($action) {

    demo {
		./BlueGreenDeployment.Kubernetes.ps1 -action initialDeploymentToProd -clearScreen $false
		pause
		./BlueGreenDeployment.Kubernetes.ps1 -action deployToStaging -clearScreen $false
		pause
		./BlueGreenDeployment.Kubernetes.ps1 -action getInfo -clearScreen $false
		pause
		./BlueGreenDeployment.Kubernetes.ps1 -action switchStagingToProd -clearScreen $false
		pause
		./BlueGreenDeployment.Kubernetes.ps1 -action getInfo -clearScreen $false
    }
	deleteDeployments {
		./BlueGreenDeployment.Kubernetes.ps1 -action deleteDeployments -clearScreen $false
	}
}

Write-Host "End of demo" -ForegroundColor DarkYellow
