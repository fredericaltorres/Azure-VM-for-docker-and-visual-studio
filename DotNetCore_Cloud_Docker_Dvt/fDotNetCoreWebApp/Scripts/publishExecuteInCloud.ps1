[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)]
	[Alias('a')]
    [string]$action = "BuildPush" # BuildPushInstantiate, deleteInstance, BuildPush
)
cls

switch($action) {

	BuildPush { 
        
        Write-Host "About to build, publish and execute this .NET Core project as a Azure Container" -ForegroundColor Yellow

        ./Scripts/deployContainerToAzureContainerRegistry.ps1 -action build -clearScreen $false
        ./Scripts/deployContainerToAzureContainerRegistry.ps1 -action push -clearScreen $false

        Write-Host "Container published in Azure Container Registry" -ForegroundColor Yellow
    }

    BuildPushInstantiate { 
        
        Write-Host "About to build, publish and execute this .NET Core project as a Azure Container" -ForegroundColor Yellow

        ./Scripts/deployContainerToAzureContainerRegistry.ps1 -action build -clearScreen $false
        ./Scripts/deployContainerToAzureContainerRegistry.ps1 -action push -clearScreen $false
        ./Scripts/deployContainerToAzureContainerRegistry.ps1 -action instantiate -clearScreen $false        

        Write-Host "Container instance should be running in Azure, start by opening the resource group in the Azure portal" -ForegroundColor Yellow
    }
 
    deleteInstance {

        ./Scripts/deployContainerToAzureContainerRegistry.ps1 -action deleteInstance -clearScreen $false
    }
}
