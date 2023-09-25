#!/bin/bash

# Function to stop container when script is terminated
cleanup() {
  echo "Stopping container..."
  docker stop jpl_config_container
}

# Trap SIGINT and call cleanup function
trap cleanup SIGINT SIGTERM

# Build and run the container in interactive mode with --init
#docker build -t jpl_config -f config/jpl_config.Dockerfile .
docker buildx build --load --platform linux/amd64 -t jpl_config -f config/jpl_config.Dockerfile --progress=plain . 2>&1 | tee build.log
docker run -it --rm --name jpl_config_container --init -v ${PWD}:/usr/local/bin/jpl_config -p 8888:8888 jpl_config
