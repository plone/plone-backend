### Defensive settings for make:
#     https://tech.davis-hansson.com/p/make/
SHELL:=bash
.ONESHELL:
.SHELLFLAGS:=-xeu -o pipefail -O inherit_errexit -c
.SILENT:
.DELETE_ON_ERROR:
MAKEFLAGS+=--warn-undefined-variables
MAKEFLAGS+=--no-builtin-rules

IMAGE_NAME=plone/plone-backend
IMAGE_TAG=6.0.0a3
IMAGE_VARIATIONS=python39 python38 python37
IMAGE_DEFAULT_VARIATION=python39
IMAGE_ADDITIONAL_TAGS=

# We like colors
# From: https://coderwall.com/p/izxssa/colored-makefile-for-golang-projects
RED=`tput setaf 1`
GREEN=`tput setaf 2`
RESET=`tput sgr0`
YELLOW=`tput setaf 3`

.PHONY: all
all: build-images

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
.PHONY: help
help: ## This help message
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: build-images
build-images:  ## Build Docker Images
	@echo "Building $(IMAGE_NAME):$(IMAGE_TAG)"
	$(foreach VARIATION,$(IMAGE_VARIATIONS),docker build . -t $(IMAGE_NAME):$(IMAGE_TAG)-${VARIATION} -f Dockerfile.${VARIATION};)

.PHONY: tag-images
tag-images:  ## Tag images
	@echo "Tag $(IMAGE_NAME):$(IMAGE_TAG)-${IMAGE_DEFAULT_VARIATION} as $(IMAGE_NAME):$(IMAGE_TAG)"
	@docker tag $(IMAGE_NAME):$(IMAGE_TAG)-${IMAGE_DEFAULT_VARIATION} $(IMAGE_NAME):$(IMAGE_TAG)
	@echo "Tag $(IMAGE_NAME):$(IMAGE_TAG) with additional tags, if any"
	$(foreach TAG,$(IMAGE_ADDITIONAL_TAGS),docker tag $(IMAGE_NAME):$(IMAGE_TAG) $(IMAGE_NAME):$(TAG);)

.PHONY: push-images
push-images:  ## Push docker image to dockerhub
	@echo "Push $(IMAGE_NAME):$(IMAGE_TAG) to Docker Hub"
	@docker push $(IMAGE_NAME):$(IMAGE_TAG)
	@echo "Push $(IMAGE_NAME):$(IMAGE_TAG) additional tags to Docker Hub"
	$(foreach TAG,$(IMAGE_ADDITIONAL_TAGS),docker push $(IMAGE_NAME):$(TAG);)
	@echo "Push all $(IMAGE_NAME):$(IMAGE_TAG) variations to Docker Hub"
	$(foreach VARIATION,$(IMAGE_VARIATIONS),docker push $(IMAGE_NAME):$(IMAGE_TAG)-${VARIATION};)

.PHONY: release
release: build-images push-images ## Build and push the image to docker hub
	@echo "Releasing $(IMAGE_NAME):$(IMAGE_TAG)"
