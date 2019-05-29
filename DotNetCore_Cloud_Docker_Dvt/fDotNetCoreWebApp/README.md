# fDotNetCoreWebApp

## Overview
A asp.net mvc .NET code 2.2 app, for testing different deployments and execution:
- Locally in docker
- In Azure Kubernetes Service (AKS)

## Container Image
The powershell script [deployContainerToAzureContainerRegistry.ps1](./Scripts/deployContainerToAzureContainerRegistry.ps1) allow to
- Build the container image in the local docker
- Tag the image with the last version and publish the image in a Azure Container Registry
- Start one instance of the container image into Azure Container Instance
- Stop and delete the container image instance running in Azure Container Instance

## Blue/Green deployment with Kubernetes

The powershell script [DemoBlueGreen.ps1](./Kubernetes/DemoBlueGreen.ps1) demonstrates a blue/green or staging/production deployment of the web application.
1. Version 1.0.2 is deployed on 2 pods using docker image, then a load balancer 1 is setup. This is the `production` environment.
2. Version 1.0.4 is deployed on 2 pods using docker image, then a load balancer 2 is setup. This is the `staging` environment. On the staging environment the new version can be tested.
3. The load balancer 1 is set to point to deployment of version 1.0.4, the new 1.0.4 version is now in `production`.
4. A production issue is detected, the load balancer 1 is reset to point to deployment of version 1.0.2.

Finally we delete both `production` and `staging` environment

- The Kubernetes Yaml files are located in the Kubernetes\Templates folder, the file are preprocessed by some Powershell scripts.
- All Powershell scripts are located in the Kubernetes folder.

## Reference
- [Starting with Docker and ASP.NET Core](https://zubialevich.blogspot.com/2019/04/starting-with-docker-and-aspnet-core.html)
