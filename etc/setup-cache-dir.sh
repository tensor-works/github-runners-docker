#!/bin/bash

DEFAULT_CACHE_DIR="$HOME/.github-action-cache"

if [ -f .env ] && grep -q DOCKER_CACHE_DIR .env; then
    EXISTING_CACHE_DIR=$(grep DOCKER_CACHE_DIR .env | cut -d '=' -f2)
    echo "DOCKER_CACHE_DIR already exists in .env file: $EXISTING_CACHE_DIR"
    mkdir -p "$EXISTING_CACHE_DIR"
    echo "Created directory: $EXISTING_CACHE_DIR"
else
    read -p "Enter GitHub Actions cache directory (default: $DEFAULT_CACHE_DIR): " cachedir
    cachedir=${cachedir:-$DEFAULT_CACHE_DIR}
    echo "DOCKER_CACHE_DIR=$cachedir" >> .env
    echo "Added DOCKER_CACHE_DIR=$cachedir to .env file"
    mkdir -p "$cachedir"
    echo "Created directory: $cachedir"
fi

mkdir -p ${DOCKER_CACHE_DIR}/.registry

echo "GitHub Actions cache directory setup complete."