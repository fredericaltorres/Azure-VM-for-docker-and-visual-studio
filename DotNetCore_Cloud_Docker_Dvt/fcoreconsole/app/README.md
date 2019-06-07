# How to build and run this dot net core console as docker container locally and in Azure

## Introduction
This is a dot net core console which in its default execution mode in a 
**Docker Container** execute the following every 10 seconds
- Create a text file locally
- Upload the text file to an Azure storage
- Enqueue the file name into an azure queue

Running the same console from a Windows or Linux machine, we can execute the following command

```bash
fCoreConsoleAzureStorage dirStorage
fCoreConsoleAzureStorage clearStorage
fCoreConsoleAzureStorage clearQueue
fCoreConsoleAzureStorage sendMessage
fCoreConsoleAzureStorage help
```

The main idea is to be able to send command to the console application instance running in the container from another machine.

## Build and deployment

Here are the following steps 

1. Build and debug the application locally
1. Build the container image and run it as a local container (No debugging from visual studio was setup)
1. Publish the container image to an Azure Container Registry
1. Instance an container instance and execute the console
1. Delete the instance of the container 

The powershell script `deployContainerToAzureContainerRegistry.ps1` can execute one of these steps.
The powershell script `executeInCloud.ps1` can execute steps
- 1, 2, 3, 4 or
- 5

### Setup

- Install Dotnet Core Runtime 2.2 and dotnet core SDK 2.2 from this [link](https://dotnet.microsoft.com/download)

### Reference

[Tutorial: Containerize a .NET Core app](https://docs.microsoft.com/en-us/dotnet/core/docker/build-container)

## How to build and run this dot net core console as docker container locally 

```bash
# build locally
dotnet publish -c Release
# check this folde exist .\app\bin\Release\netcoreapp2.2\publish

# build container image locally
docker build -t fcoreconsoleazurestorage .

# Create and run a container instance from the last image attached to the current console
docker run -it fcoreconsoleazurestorage

# Create container instance
docker create fcoreconsoleazurestorage

# Find container instance id or code-name
docker ps -a

# start instance
docker start 13b7cc1fba11   

# view output of the console/ container log
docker logs 13b7cc1fba11   # see output on the fly

# See container internal configuration
docker inspect  e0dc418842ce

# Connect to container using bash
docker exec  9fb88d2109fe  "bin/bash"

# stop container instance
docker stop 13b7cc1fba11   

# delete container instance
docker delete 13b7cc1fba11   
```

## How to publish the docker image into an Azure Container Registry
The powershell script [deployContainerToAzureContainerRegistry.ps1](./deployContainerToAzureContainerRegistry.ps1) allow
to 
- build the .net project and create a docker container image locally tagged with the project version
- push the last build container image to an My Azure Container Registry

## How to instantiate a container instance from a the docker image stored into Azure Container Registry
The powershell script [deployContainerToAzureContainerRegistry.ps1](./deployContainerToAzureContainerRegistry.ps1) allow
to 
- Instanciate a container instance and run the console app
- Stop and delete the container instance
