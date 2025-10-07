## Defensive settings for make:
#     https://tech.davis-hansson.com/p/make/
SHELL:=bash
.ONESHELL:
.SHELLFLAGS:=-xeu -o pipefail -O inherit_errexit -c
.SILENT:
.DELETE_ON_ERROR:
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules

NIGHTLY_IMAGE_TAG=nightly

# We like colors
# From: https://coderwall.com/p/izxssa/colored-makefile-for-golang-projects
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
YELLOW=`tput setaf 3`

# Current version
MAIN_IMAGE_NAME=plone/plone-backend
CLASSICUI_IMAGE_NAME=plone/plone-classicui
BASE_IMAGE_NAME=plone/server
PYTHON_VERSIONS=$$(cat versions.json | jq -r '.[]')


.PHONY: all
all: help

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
.PHONY: help
help: # This help message
	@grep -E '^[a-zA-Z_-]+:.*?# .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?# "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

# Build image
.PHONY: show-images
show-images: ## Print Image Names
	@for v in $(PYTHON_VERSIONS); do \
		echo "$(BASE_IMAGE_NAME)-builder:uv-$$v"; \
		echo "$(BASE_IMAGE_NAME)-prod-config:uv-$$v"; \
	done

.PHONY: image-builder
image-builder:  ## Build Base Image
	@for v in $(PYTHON_VERSIONS); do \
		echo "Building $(BASE_IMAGE_NAME)-builder:uv-$$v"; \
		docker buildx build . --no-cache --build-arg PYTHON_VERSION=$$v -t $(BASE_IMAGE_NAME)-builder:uv-$$v -f Dockerfile.builder --load; \
	done

.PHONY: image-prod-config
image-prod-config:  ## Build Prod Image
	@for v in $(PYTHON_VERSIONS); do \
		echo "Building $(BASE_IMAGE_NAME)-prod-config:uv-$$v"; \
		docker buildx build . --no-cache --build-arg PYTHON_VERSION=$$v -t $(BASE_IMAGE_NAME)-prod-config:uv-$$v -f Dockerfile.prod --load; \
	done

.PHONY: build-images
build-images:  ## Build Images
	@echo "Building all UV-based images"
	$(MAKE) image-builder
	$(MAKE) image-prod-config
