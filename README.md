# Information about doing docker development using Visual Studio from an Azure VM

## Azure VM

### Creation

* Create VM of type: 'Standard E4 v3' (4 vcpus, 32 GB memory), VM of type 'E* v3' comes with HyperV supported

Reference Documents
* [Installing docker on azure virtual machine windows 10](https://stackoverflow.com/questions/44817161/installing-docker-on-azure-virtual-machine-windows-10)
* [How to enable nested virtualization in Azure](https://rlevchenko.com/2017/07/24/how-to-enable-nested-virtualization-in-azure/)

### VM Configuration

VM Configuration with PowerShell
```PowerShell
 
# Step 1 - Ensure Windows Hyper-V featutes are enabled by running PowerShell cmdlet:
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Verbose
# You should be asked to reboot.

# Step 2 - Ensure Windows Containers feature is enabled by running PowerShell cmdlet:
Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -Verbose

#Ensure Hypervisor is set to auto start in the Boot Configuration Database (BCD) by running in elevated command prompt the command:
bcdedit /set hypervisorlaunchtype Auto

# Reboot
```

## Docker

### Installation
Download and install Docker

- [Install Docker Desktop for Windows](https://docs.docker.com/docker-for-windows/install)
You will be asked to log out and log in.

### Testing the Docker Installation

#### Hyper V Manager
- Start Hyper-V Manager. You should see the MobyLinuxVM running inside.

#### Docker account
    - Create an account http://hub.docker.com
    Login: docker login # username:usual, password:cat

#### Testing local installation of Docker
```powershell
    C:\>docker version # Show the docker client side and server side
```
        Client: Docker Engine - Community
        OS/Arch:           windows/amd64
        Experimental:      false
        Server: Docker Engine - Community
        OS/Arch:          linux/amd64

```powershell
    docker ps # Process
    docker images # images
```

```powershell
    # https://hub.docker.com/_/hello-world?tab=description
    docker pull library/hello-world # download an hello-world image container
    docker run library/hello-world # execute an hello-world image container
    docker ps --all # Show history of container execution
    docker run ubuntu /bin/bash -c "echo Hello World"

    # Run a container in background
    docker run --detach --name helloworld  ubuntu /bin/bash -c "while true; do echo Hello World; sleep 1; done"
    docker logs helloworld # see the output of the container
    docker exec helloworld "uname" # run command uname inside the running container which output the name of the OS
    docker stop helloworld # stop running container

    docker run --rm -it microsoft/dotnet:2-runtime dotnet --info
    docker inspect container-name
```

## Visual Studio and Git

[Download Git](https://git-scm.com/download/win)
[Download Visual Studio 2019 Pro or Community Edition](https://www.google.com)

### Create an ASP.NET Core Web App, Rest API with Docker support.
- Create an ASP.NET Core Web App, Rest API with Docker support.
    * Run inside IIS Express: https://localhost:44389/api/values
    * Run inside a container
- When running app for the first time IIS Express mode or Docker mode may fail, but run the second times.

```powershell
dotnet run # will compile and run the app from the command line
docker run --rm -it microsoft/dotnet:2-runtime
docker run --rm -it microsoft/aspnetcore:2
docker run --rm -it -v ${PWD}:/api microsoft/dotnet:2-runtime # Should be able to mount the source code inside 
```

### Publish to Azure Container Registry
- name:fredcontainerregistry2,
- Use option to create registry from Visual Studio
https://fredcontainerregistry2.azurewebsites.net/

