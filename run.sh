#!/bin/bash
set -e

PORT=8877

if [ "$(docker ps -aq -f name=asm-server-runner)" ]; then
    echo "Stopping existing container..."
    docker stop asm-server-runner
    docker rm asm-server-runner
fi

echo "Running asm-server on port $PORT..."
docker run --platform linux/amd64 -p $PORT:8877 --name asm-server-runner asm-server
