#!/bin/bash

# UBKGBox ubkg-front-end container entrypoint
# Configures the container to run nginx as a non-root user named ubkg.

# Pass the HOST_UID and HOST_UID from environment variables specified in docker-compose
HOST_GID=${HOST_GID}
HOST_UID=${HOST_UID}

echo "Starting ubkg-front-end container with the same host user UID: $HOST_UID and GID: $HOST_GID"

# Create a new user with the same host UID to run processes on container, named "ubkg".
# The username diverges from the standard hubmapconsortium user name of "hubmap".

# The Filesystem doesn't really care what the user is called--
# it only cares about the UID attached to that user.
# Check if user already exists and don't recreate across container restarts
getent passwd $HOST_UID > /dev/null 2&>1
# $? is a special variable that captures the exit status of last task
if [ $? -ne 0 ]; then
    groupadd -r -g $HOST_GID ubkg
    useradd -r -u $HOST_UID -g $HOST_GID -m ubkg
fi
touch /var/run/nginx.pid
chown -R ubkg:ubkg /var/run/nginx.pid
chown -R ubkg:ubkg /var/cache/nginx
chown -R ubkg:ubkg /var/log/nginx

# Modify the neo4j instructions in the home page in the container to point to the mapped Bolt port of
# the ubkg-front-end service. The Bolt port is passed to the Dockerfile via the ubkg-box's
# Docker Compose in the environment variable BOLT_PORT.
echo "Updating home page for ubkg-back-end's Bolt port: $BOLT_PORT"
sed -i "s/BOLT_PORT/$BOLT_PORT/g" "/usr/share/nginx/home.html"

# Lastly we use su-exec to execute our process "$@" as the non-root user.
# Remember CMD from a Dockerfile of child image gets passed to the entrypoint.sh as command line arguments
# "$@" is a shell variable that means "all the arguments".
exec /usr/local/bin/su-exec ubkg "$@"
