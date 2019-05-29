# fDotNetCoreWebApp

## Overview
A asp.net mvc .NET code 2.2 app, for testing different deployments and execution:
- Locally in docker
- In Azure Kubernetes Service (AKS)

## Projection Creation
- [Starting with Docker and ASP.NET Core](https://zubialevich.blogspot.com/2019/04/starting-with-docker-and-aspnet-core.html)


## Container Image
The powershell script [deployContainerToAzureContainerRegistry.ps1](./Scripts/deployContainerToAzureContainerRegistry.ps1) allow to
- Build the container image in the local docker
- Tag the image with the last version and publish the image in a Azure Container Registry
- Start one instance of the container image into Azure Container Instance
- Stop and delete the container image instance running in Azure Container Instance

```powershell
```

## Reference
