# How to build and run this dot net core console as docker container locally and in Azure

## How to build and run this dot net core console as docker container locally 

```bash
# build locally
dotnet publish -c Release
# check this folde exist .\app\bin\Release\netcoreapp2.2\publish

# build container image locally
docker build -t fcoreconsoleazurestorage .


# Create container instance
docker create fcoreconsoleazurestorage
# Find container instance id or code-name
docker ps -a
# start instance
docker start 13b7cc1fba11   
# view output of the console/ container log
docker logs 13b7cc1fba11   # see output on the fly
# stop container instance
docker stop 13b7cc1fba11   
# delete container instance
docker delete 13b7cc1fba11   
```

## How to publish the docker image into an Azure Container Registry
- TODO

## How to instantiate a container instance from a the docker image stored into Azure Container Registry
- TODO