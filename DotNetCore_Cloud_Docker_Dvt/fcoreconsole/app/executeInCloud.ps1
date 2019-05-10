cls
Write-Host "About to build, publish and execute this .NET Core project as a Azure Container" -ForegroundColor Yellow

./deployContainerToAzureContainerRegistry.ps1 -action build
./deployContainerToAzureContainerRegistry.ps1 -action push
./deployContainerToAzureContainerRegistry.ps1 -action instantiate

Write-Host "Container instance should be running in Azure, start by opening the resource group in the Azure portal" -ForegroundColor Yellow

# ./deployContainerToAzureContainerRegistry.ps1 -action deleteInstantiate