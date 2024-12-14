> [Go to Home](../docker-labs.md)

# Section 1: General Commands.

1. Docker information

```powershell
docker
```

Output:
![docker-info-1](./docker-info-1.png) 2. Docker Installation system information.

```powershell
docker info
```

output:
![docker-info-system](./docker-info-2.png) 3. Docker version

```powershell
docker version
```

output:
![docker-verison](./docker-version.png)

# Section 2: Image related commands.

1. search for **Ubuntu** Image.

```powershell
docker search ubuntu | docker search ubuntu:latest
```

output:
![docker-ubuntu-latest](docker-ubuntu-1.png) 2. Searching **Ubuntu** image with filters on.

```powershell
docker search --filter is-official=true --filter stars=3 --limit 2 ubuntu
```

output:
![docker-ubuntu-filter](./docker-ubuntu-filter.png)

# Section 3: Pull image to your Docker registry.

1. Pull **Ubuntu** to your registry.

```powershell
docker pull ubuntu | docker image pull ubuntu
```

output:
![docker-ubuntu-pull](./docker-ubuntu-filter.png) 2. Pull **Ubuntu** with a _specific tag_.

```powershell
docker pull ubuntu:22.04
```

output:
![docker-ubuntu-tag-search](./docker-ubuntu-tag-search.png)
![docker-pull-ubuntu-tag](./docker-ubuntu-tag.png) 3. Pull more images

```powershell
docker pull nginx # A popular web server implementation
docker pull mysql # A popular relational database
```

output:
![docker-pull-more-images](./docker-pull-nginx-mysql.png)
![docker-desktop-images](./docker-desktop-images-list.png) 4. List all layers of images (no truncation)

```powershell
docker images --no-trunc
```

output:
![docker-images-no-trunc](./docker-images-no-trunc.png) 5. Remove All unused (dangling) images

```powershell
docker image prune
```

output:
![docker-image-prune.png](./docker-image-prune.png) 6. Remove all unused images by container

```powershell
docker image prune -a
```

output:
![docker-images-prune-all.png](./docker-images-prune-all.png)

---

# Previous: [Steps To install Docker](../ACM-01/Steps%20To%20install%20Docker.md)

# Next: [Docker Networking and Inter Container Communication](../ACM-03/Docker%20Networking%20and%20Inter%20Container%20Communication.md)
