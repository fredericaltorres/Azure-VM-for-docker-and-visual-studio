# fDotNetCoreWebApp

## Overview
A asp.net mvc .NET code 2.2 app, for testing different deployments and execution:
- Localy in dockers
- In Azure Kubernetes Service (AKS)

## Projection Creation
- [Starting with Docker and ASP.NET Core](https://zubialevich.blogspot.com/2019/04/starting-with-docker-and-aspnet-core.html)

dotnet new webapp #    Web/MVC/Razor Pages

## Building and running container image locally

```powershell
C:\> docker build -t fdotnetcorewebapp . # Build image
# Run locally, try http://localhost:8080

C:\> docker run -d -p 8080:80 --name fdotnetcorewebapp fdotnetcorewebapp:latest
C:\> docker stop fdotnetcorewebapp # Stop
C:\> docker rm fdotnetcorewebapp # Remove
```

## Reference

