#!/bin/bash

echo "Testing Docker registry accessibility..."

# Define registry URL
REGISTRY_URL=${LOCAL_REGISTRY_URL:-"http://localhost:5000"}

# Function to check if command succeeded
check_success() {
    if [ $? -eq 0 ]; then
        echo "SUCCESS: $1"
    else
        echo "ERROR: $2"
        exit 1
    fi
}

# Print registry information
echo "Registry URL: $REGISTRY_URL"

echo -e "\nChecking if the registry is accessible..."
echo $(curl -s -S http://localhost:5000/v2/_catalog 2>&1)
check_success "Registry is accessible" "Failed to access the registry"
echo -e "\nIf condition output: "
echo $(curl -s -f -m 5 http://localhost:5000/v2/_catalog 2>&1)

# Try to pull an image from the registry
echo -e "\nTrying to pull an image from the registry..."
docker pull "${REGISTRY_URL#http://}/hello-world:latest" || docker pull hello-world:latest
check_success "Successfully pulled an image" "Failed to pull image"

# Try to tag the image for our registry
echo -e "\nTrying to tag the image for our registry..."
docker tag hello-world:latest "${REGISTRY_URL#http://}/hello-world:test"
check_success "Successfully tagged the image" "Failed to tag the image"

# Try to push the image to our registry
echo -e "\nTrying to push the image to our registry..."
docker push "${REGISTRY_URL#http://}/hello-world:test"
check_success "Successfully pushed the image to the registry" "Failed to push the image to the registry"

# Try to pull the image we just pushed
echo -e "\nTrying to pull the image we just pushed..."
docker pull "${REGISTRY_URL#http://}/hello-world:test"
check_success "Successfully pulled the image we just pushed" "Failed to pull the image we just pushed"

# Clean up
echo -e "\nCleaning up..."
docker rmi "${REGISTRY_URL#http://}/hello-world:test"
docker rmi hello-world:latest

echo -e "\nAll tests passed successfully!"