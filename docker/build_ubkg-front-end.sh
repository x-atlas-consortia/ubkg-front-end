#!/bin/bash
# -------------------------
# Unified Biomedical Knowledge Graph (UBKG)
# Builds and pushes the ubkg-front-end component of a UBKGBox multi-container application

if [ "$1" = "build" ]; then
  docker compose -f development-docker-compose.yml -f docker-compose.yml -p ubkg-front-end build
elif [ "$1" = "push" ]; then
  # buildx uses docker-compose.yml to publish in multiple architectures
  docker buildx bake -f development-docker-compose.yml -f docker-compose.yml  --push
fi