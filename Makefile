# Determine the operating system
ifeq ($(OS),Windows_NT)
    DETECTED_OS := Windows
    DEFAULT_CACHE_DIR := $(shell powershell -Command "Join-Path $$env:USERPROFILE '.github-action-cache'")
    CHECK_CACHE_DIR := powershell -Command "if (Test-Path .env) { $$env = Get-Content .env -Raw | ConvertFrom-StringData; if ($$env.DOCKER_CACHE_DIR) { Write-Output $$env.DOCKER_CACHE_DIR } }"
else
    DETECTED_OS := $(shell uname -s)
    DEFAULT_CACHE_DIR := $(HOME)/.github-action-cache
    CHECK_CACHE_DIR := if [ -f .env ] && grep -q DOCKER_CACHE_DIR .env; then grep DOCKER_CACHE_DIR .env | cut -d '=' -f2; fi
endif

# Docker image name and tag
IMAGE_NAME := tensorpod/actions-image
IMAGE_TAG := latest

.PHONY: setup
setup:
	$(eval EXISTING_CACHE_DIR := $(shell $(CHECK_CACHE_DIR)))
	@if [ -n "$(EXISTING_CACHE_DIR)" ]; then \
		echo "DOCKER_CACHE_DIR already exists in .env file: $(EXISTING_CACHE_DIR)"; \
		if [ "$(DETECTED_OS)" = "Windows" ]; then \
			powershell -Command "if (-not (Test-Path '$(EXISTING_CACHE_DIR)')) { New-Item -Path '$(EXISTING_CACHE_DIR)' -ItemType Directory; Write-Host 'Created directory: $(EXISTING_CACHE_DIR)' }"; \
		else \
			mkdir -p "$(EXISTING_CACHE_DIR)"; \
			echo "Created directory: $(EXISTING_CACHE_DIR)"; \
		fi; \
	else \
		if [ "$(DETECTED_OS)" = "Windows" ]; then \
			powershell -Command " \
				$$cachedir = Read-Host 'Enter GitHub Actions cache directory (default: $(DEFAULT_CACHE_DIR))'; \
				if (-not $$cachedir) { $$cachedir = '$(DEFAULT_CACHE_DIR)' }; \
				if (-not (Test-Path .env -PathType Leaf)) { New-Item .env -ItemType File }; \
				Add-Content -Path .env -Value \"DOCKER_CACHE_DIR=$$cachedir\"; \
				Write-Host \"Added DOCKER_CACHE_DIR=$$cachedir to .env file\" \
			"; \
		else \
			read -p "Enter GitHub Actions cache directory (default: $(DEFAULT_CACHE_DIR)): " cachedir; \
			cachedir=$${cachedir:-$(DEFAULT_CACHE_DIR)}; \
			echo "DOCKER_CACHE_DIR=$$cachedir" >> .env; \
			echo "Added DOCKER_CACHE_DIR=$$cachedir to .env file"; \
		fi; \
	fi
	@echo "GitHub Actions cache directory setup complete."


.PHONY: build
build:
	@echo "Building Docker image..."
	docker build -t $(IMAGE_NAME):$(IMAGE_TAG) -f Dockerfiles/Dockerfile.dood .

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

.PHONY: test
test: setup
	docker-compose run --rm test

.PHONY: test-buildx
test-buildx:
	@echo "Testing Docker Buildx setup..."
	@docker run --rm \
		-v /var/run/docker.sock:/var/run/docker.sock \
		--entrypoint /test_buildx.sh \
		$(IMAGE_NAME):$(IMAGE_TAG)