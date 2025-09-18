#!/bin/bash
set -e

echo "Building Docker image asm-server for platform linux/amd64..."
docker build --platform linux/amd64 -t asm-server .
echo "Build completed."
