#!/bin/bash

# Start nginx in background
# 'daemon off;' is nginx configuration directive
nginx -g 'daemon off;' &

# Command to keep the container running indefinitely so as not to exit with code 0.
# This is a divergence from the hubmapconsortium standard api docker build. Docker containers
# of Flask APIs run uwsgi, which keeps the container open.
tail -f /dev/null