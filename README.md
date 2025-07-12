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

# Initialization of the neo4j Query Plan Cache
When a Cypher query is executed for the first time in a new neo4j instance, neo4j
must add the query plan to its [plan cache](https://neo4j.com/developer/kb/understanding-the-query-plan-cache/). 
Plan caching results in the initial execution of the query taking longer than subsequent executions.

In the ubkg-api in UBKGBox, the initial execution of an endpoint may fail with a HTTP 500 error 
because of delays or other issues related to query plan caching in the neo4j database. Because the Guesdt
application obtains content by using the ubkg-api, failures in the ubkg-api means that the Guesdt page will 
not load correctly.

To address this issue, the front end executes the shell script **prime_api.sh** that 
submits via curl a set of known endpoints in the ubkg-api immediately after the neo4j
instance is ready. At least the first such request to the endpoint will fail. This is akin to priming a pump. 

Executing an initial set of queries in neo4j before a user 
has the opportunity to execute a query mitigates the risk
of the Guesdt application failing in the initial load of its index.html page.

# nginx configuration

The UBKGBox front end has a complex nginx configuration because of its multiple roles 
as host for the UBKG home page and reverse proxy for the other **UBKGBox** services. 

### UMLS authorization
The majority of the locations in the nginx configuration proxy to the **umls_auth** service.
The **umls-auth** service authenticates a supplied UMLS API key against the UMLS API.

Some routes bypass authentication because they originate from the service sites. These include:

| location        | supports  | action                                                             |
|-----------------|:----------|--------------------------------------------------------------------|
| /               | front end | external URLs                                                      |
| /static/        | Guesdt    | requests for static resources from pages of the Guesdt application |
| /userguide.html | Guesdt    | Requests for the static User Guide page in the Guesdt application  |
|/neo4j/browser| neo4j| internal redirects from neo4j|
|(regex)|neo4j|requests for static resources from neo4j|

## neo4j support
Much of the front end's nginx configuration supports integration with the neo4j browser for the neo4j instance
hosted in the **ubkg-back-end** service. Important characteristics of the neo4j browser include:
1. It is a [single page application](https://en.wikipedia.org/wiki/Single-page_application) that emits many redirects to itself
2. It uses both the http and bolt protocols. 

To support the neo4j browser, the nginx configuration features:
1. In the main location (_/neo4j/browser_), 
   - Use of _proxy_redirect_ directives to handle redirects from neo4j 
   - Use of WebSockets (for the bolt protocol)
2. The _/neo4j/browser_ location to handle neo4j redirects
3. A location to handle requests for static resources (JavaScript) from the neo4j browser
4. A separate stream for the bolt protocol

## UBKGBox subnodes
The front end assumes that there are network subnodes defined for downstream UBKG services. 
The only required subnode is one named **neo4j.ubkg.com**, to allow reverse proxying to the neo4j browser hosted 
by the **ubkg-back-end** service.

Refer to the README.md in the ubkg-box repository for details.
