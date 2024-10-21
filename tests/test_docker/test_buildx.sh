#!/bin/bash

echo "Testing Docker Buildx setup..."

# Check if Docker is accessible
if ! docker info &> /dev/null; then
    echo "ERROR: Cannot connect to Docker daemon. Is Docker running and accessible?"
    exit 1
fi

# Check if Buildx plugin is installed
if ! docker buildx version &> /dev/null; then
    echo "ERROR: Docker Buildx plugin is not installed or not accessible."
    exit 1
fi

# Create a new builder instance
echo "Creating a new Buildx builder instance..."
if ! docker buildx create --name testbuilder &> /dev/null; then
    echo "ERROR: Failed to create a new Buildx builder instance."
    exit 1
fi

# List available builders
echo "Listing available Buildx builders..."
if ! docker buildx ls; then
    echo "ERROR: Failed to list Buildx builders."
    docker buildx rm testbuilder &> /dev/null
    exit 1
fi

# Remove the test builder
echo "Removing test Buildx builder..."
if ! docker buildx rm testbuilder &> /dev/null; then
    echo "ERROR: Failed to remove test Buildx builder."
    exit 1
fi

echo "Buildx test completed successfully!"
exit 0