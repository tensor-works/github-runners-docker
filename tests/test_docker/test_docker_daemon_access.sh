#!/bin/bash

echo "Testing Docker daemon accessibility..."

# Print Docker host information
echo "Docker host: $DOCKER_HOST"

# Try to list Docker containers
echo "Attempting to list Docker containers..."
if docker ps; then
    echo "SUCCESS: Docker daemon is accessible."
else
    echo "ERROR: Failed to access Docker daemon. Error details:"
    docker ps 2>&1
    exit 1
fi

# Try to run a simple Docker command
echo -e "\nTrying to run a simple Docker container..."
if docker run --rm hello-world; then
    echo "SUCCESS: Successfully ran a Docker container."
else
    echo "ERROR: Failed to run a Docker container. Error details:"
    docker run --rm hello-world 2>&1
    exit 1
fi

echo -e "\nAll tests passed successfully!"