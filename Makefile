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
# Current version
IMAGE_TAG=`python helpers/version.py`
NIGHTLY_IMAGE_TAG=nightly

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

current-version: # Print current version
	@echo "Current version: $(IMAGE_TAG)"

create-tag: # Create a new tag using git
	@echo "Creating new tag $(VERSION)"
	if git show-ref --tags v$(IMAGE_TAG) --quiet; then echo "$(IMAGE_TAG) already exists";else git tag -a v$(IMAGE_TAG) -m "Release $(IMAGE_TAG)" && git push && git push --tags;fi

commit-release: # Commit new version change and create tag
	@echo "Commiting changes"
	@git commit -am "Use Plone $(VERSION)"
	make create-tag

.PHONY: build-image
build-image:  ## Build Docker Image
	@echo "Building $(IMAGE_NAME):$(IMAGE_TAG)"
	@docker build . -t $(IMAGE_NAME):$(IMAGE_TAG) -f Dockerfile

.PHONY: push-image
push-image:  ## Push docker image to dockerhub
	@echo "Push $(IMAGE_NAME):$(IMAGE_TAG) to Docker Hub"
	@docker push $(IMAGE_NAME):$(IMAGE_TAG)

.PHONY: release
release: build-image push-image ## Build and push the image to docker hub
	@echo "Released $(IMAGE_NAME):$(IMAGE_TAG)"

.PHONY: build-image-nightly
build-image-nightly:  ## Build Docker Image Nightly
	@echo "Building $(IMAGE_NAME):$(NIGHTLY_IMAGE_TAG)"
	@docker build . -t $(IMAGE_NAME):$(NIGHTLY_IMAGE_TAG) -f Dockerfile.nightly --no-cache
