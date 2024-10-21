# Determine the operating system
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    DEFAULT_CACHE_DIR := $(shell powershell -Command "Join-Path $$env:USERPROFILE '.github-action-cache'")
    CHECK_CACHE_DIR := powershell -Command "if (Test-Path .env) { $$env = Get-Content .env -Raw | ConvertFrom-StringData; if ($$env.DOCKER_CACHE_DIR) { Write-Output $$env.DOCKER_CACHE_DIR } }"
    SETUP_SCRIPT := powershell -ExecutionPolicy Bypass -File etc/setup-cache-dir.ps1
else
    DETECTED_OS := $(shell uname -s)
    DEFAULT_CACHE_DIR := $(HOME)/.github-action-cache
    CHECK_CACHE_DIR := if [ -f .env ] && grep -q DOCKER_CACHE_DIR .env; then grep DOCKER_CACHE_DIR .env | cut -d '=' -f2; fi
    SETUP_SCRIPT := bash etc/setup-cache-dir.sh
endif

# Docker image name and tag
IMAGE_NAME := tensorpod/actions-image
IMAGE_TAG := latest

.PHONY: setup
setup:
	@echo "Setting up GitHub Actions cache directory..."
	@$(SETUP_SCRIPT)

# Function to load .env and export variables
.PHONY: load_env
load_env: 
	@echo "Loading environment variables..."
	$(eval include .env)
	$(eval export)

.PHONY: build
build: setup load_env
	@echo "Building Docker image..."
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f Dockerfiles/Dockerfile.dood . --build-arg DOCKER_CACHE_DIR=$(DOCKER_CACHE_DIR)

.PHONY: up
up: setup
	docker-compose up -d

.PHONY: down
down:
	@echo "Stopping and removing containers..."
	docker-compose down


.PHONY: logs
logs:
	docker-compose logs -f

.PHONY: clean
clean:
	docker-compose down -v
	rm -f .env

.PHONY: test-daemon
test: setup
	@echo "Testing DOOD daemon access..."
	@docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--entrypoint /test_docker_daemon_access.sh \
		$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: test-buildx
test-buildx:
	@echo "Testing Docker Buildx setup..."
	@docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--entrypoint /test_buildx.sh \
		$(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: test-registry
test-registry: setup
	@echo "Testing registry access..."
	@docker-compose run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--entrypoint /bin/bash \
		runner \
		-c "/test_registry_access.sh"