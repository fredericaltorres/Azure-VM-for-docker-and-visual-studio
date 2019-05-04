# Fred Node App In Container

## How to build the container

```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker build -t $imageTag .
docker images $imageTag
```

## How to run the image

```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker run -p 49160:8080 -d $imageTag
3474e4f9c8738ec1fe37f5a164e09e01e0c8e9c1bfbcd4f1ba2a61d7e9cf97dd

docker ps # Get container ID

docker logs 3474e4f9c873    # Print app output

$ docker exec -it 3474e4f9c873 /bin/bash # Enter the container

```

## Test the app
To test your app, get the port of your app that Docker mapped:
`
```powershell
$imageTag = "fredericaltorres/fnodeappincontainer"
docker ps $imageTag .
# Get the physical port map to 8080 in the container -> 49160

# Try this url: http://localhost:49160
```