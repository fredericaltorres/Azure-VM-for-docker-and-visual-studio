[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
	[Alias('a')]
    [string]$action = "demo" # demo, deleteDeployments
)

Import-Module ".\Util.psm1" -Force

cls

Write-HostColor "Blue Green Deployment With Kubernetes, Azure CLI, Powershell Demo" Yellow

switch($action) {

    demo {
		./BlueGreenDeployment.Kubernetes.ps1 -a initialDeploymentToProd -clearScreen $false
		pause
		./BlueGreenDeployment.Kubernetes.ps1 -a deployToStaging -clearScreen $false
		pause
		./BlueGreenDeployment.Kubernetes.ps1 -a getInfo -clearScreen $false
		pause
		./BlueGreenDeployment.Kubernetes.ps1 -a switchStagingToProd -clearScreen $false
		pause
		./BlueGreenDeployment.Kubernetes.ps1 -a getInfo -clearScreen $false
		pause
		./BlueGreenDeployment.Kubernetes.ps1 -a revertProdToPrevious -clearScreen $false
		pause
		./BlueGreenDeployment.Kubernetes.ps1 -a getInfo -clearScreen $false
		pause		
    }
	deleteDeployments {
		./BlueGreenDeployment.Kubernetes.ps1 -a deleteDeployments -clearScreen $false
	}
}

Write-Host "End of demo" -ForegroundColor DarkYellow
