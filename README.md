# ubkg-front-end

This repository contains source to build and publish the **ubkg-front-end** component of the **[UBKGBox](https://github.com/x-atlas-consortia/ubkg-box)** Docker container application.

# Supported platforms
The bash shell scripts contained in this directory are intended for use on Mac OS X or Linux. 
These scripts will not work on Windows. 
(The resulting Docker images should, however, run on Windows.)

# Build Prerequisites
## Docker
[Docker must be installed](https://docs.docker.com/engine/install/) on the development machine with Docker BuildX build support.  
By default Docker BuildX support is installed with Docker Desktop.  If you have a version of Docker installed without Desktop you can [install Docker BuildX manually](https://docs.docker.com/build/install-buildx/).

## Docker Hub
To publish **ubkg-api** images in the Docker Hub registry, the developer must be logged in to Docker Hub with an account that has privileges in the [hubmap consortium](https://hub.docker.com/orgs/hubmap/teams/consortium/members) organization.

## Docker Compose for multiple architectures
The Docker Compose workflow will push **ubkg-front-end** images to Docker Hub for both 
linux/amd64 (Intel) and linux/arm64(OSX) architectures. This requires that:
- the development machine runs two buildx builders.
- the **docker-compose.development.yml** file includes keys that enable multiple architectures (**tags** and **x-bake**)

Refer to [this article](architecture-builds-are-possible-with-docker-compose-kind-of-2a4e8d166c56) for an explanation of configuring Docker Compose for multiple architectures.

To prepare the development machine to build images in multiple architectures, run the following command:

`docker buildx create --use`

To see the list of builders on the machine, run

`docker buildx ls`

Once at least two buildx builders are available, the build workflow will build and push images in both architectures.

# Build Workflow (OSX machine)
1. Start Docker Desktop.
2. Log in to Docker Hub with a user that has access to the **hubmap** organization.
3. `./build_ubkg-front-end.sh build` will build the following in Docker:
   - an image named **hubmap/ubkg-front-end** and tag of **latest**
   - an image named **moby/buildkit** and tag **buildx-stable-1**.
   - a container named **buildx_buildkit_**_builder_, where _builder_ is the name of the additional buildx builder created as a prerequisite. 
   The last image and container correspond to the image with linux/arm64 architecture.
4. `./build_ubkg-front-end.sh push` will push tagged images for both linux/amd64 and linux/arm64 architectures to the Docker hub repo named **hubmap/ubkg-front-end**.

