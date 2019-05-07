# Information about doing docker container development using Visual Studio and NodeJS from an Azure VM

## Azure VM
First we need a machine, you may install docker on our physical machine, but you can also provision an Azure VM, which is what we are doing here.

### Creation

* Create VM of type: 'Standard E4 v3' (4 vcpus, 32 GB memory), VM of type 'E* v3' comes with HyperV supported.

Reference Documents
* [Installing docker on azure virtual machine windows 10](https://stackoverflow.com/questions/44817161/installing-docker-on-azure-virtual-machine-windows-10)
* [How to enable nested virtualization in Azure](https://rlevchenko.com/2017/07/24/how-to-enable-nested-virtualization-in-azure/)

### VM Configuration
Once the VM is running connect via RDP and execute the following PowerShell commands.

```PowerShell
# Step 1 - Ensure Windows Hyper-V featutes are enabled by running PowerShell cmdlet:
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -Verbose
# You should be asked to reboot.

# Step 2 - Ensure Windows Containers feature is enabled by running PowerShell cmdlet:
Enable-WindowsOptionalFeature -Online -FeatureName Containers -All -Verbose

# Step 3 - Ensure Hypervisor is set to auto start in the Boot Configuration Database (BCD) by running in elevated command prompt the command:
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
- We can increase the memory allocated to the MobyLinuxVM using the Hyper-V Manager UI.

#### Docker account
    - Create an account http://hub.docker.com
    Login: docker login # username:usual, password:cat

#### Testing local installation of Docker
```powershell
    C:\>docker version # Show the docker client side and server side
```
We expect the client side to be Windows and the server side to be Linux.
**Output**
```
Client: Docker Engine - Community
OS/Arch:           windows/amd64
Experimental:      false
Server: Docker Engine - Community
OS/Arch:          linux/amd64
```        

```powershell
C:\>docker ps # At this point to container process should be running
C:\>docker images ps # At this point to the contains repository should be enpty
```

- Let's download and execute an Hello World image
- For more information about the [Hello World Image](https://hub.docker.com/_/hello-world?tab=description)
```powershell
# Download from hub.docker.com as a default
C:\>docker pull library/hello-world 
C:\>docker run library/hello-world # execute 
C:\>docker ps --all # Show history of container execution
```

- Let's download a small version of Ubuntu
- Run the OS and execute a bash command
```powershell
# Download ubuntu and execute a bash command
C:\>docker run ubuntu /bin/bash -c "echo Hello World"
```

- Run the container in background mode, detached from the console

```powershell
C:\>docker run --detach --name helloworld  ubuntu /bin/bash -c "while true; do echo Hello World; sleep 1; done"
C:\>docker logs helloworld # see the output of the container
C:\>docker exec helloworld "uname" # run command uname inside the running container which output the name of the OS
docker stop helloworld # stop running container
```

- download the dotnet runtime and query for information
```powershell
C:\>docker run --rm -it microsoft/C:\>dotnet:2-runtime dotnet --info
```

- How to visualize information about a container image using the inspect tool?

```powershell
# How to get informaton about a docker image, used tool manifest-tool from weshigbee running in a container
C:\>docker run --rm weshigbee/manifest-tool inspect microsoft/dotnet:2-runtime
C:\>docker run --rm weshigbee/manifest-tool inspect microsoft/dotnet:2.0.0-preview1-runtime-jessie
```

## How to build, test, publish and instanciate a container image based on a NodeJS app in Azure
- [Download node js](https://nodejs.org/en/download/)
- The sub folder fNodeAppInContainer, contains a NodeJS REST API application, that be containerized, published to an Azure Container Registry, and instanciate multple time int the cloud using a PowerShell Script. 
- [README](fNodeAppInContainer/README.md)

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

docker stop fwebapidockerized:dev # How to stop a running container 
docker stop cde304650124 # How to stop a running container

docker rmi fwebapidockerized:dev --force # how to delete an image
docker rmi cde304650133 --force # how to delete an image

# How to build a docker image from a current aspnetcore project
docker build -f "C:\DVT\FWebApiDockerized\Dockerfile" -t fwebapidockerized:dev --target base --label "com.microsoft.created-by=visual-studio" "C:\DVT" 

```

### Publish to Azure Container Registry

***` - - - Not finished - - - `***

