NAME                  := $(shell basename $(CURDIR) | sed -e "s/^docker-//g")
REVISION              := $(shell git rev-parse --short HEAD)
ORIGIN                := $(shell git remote get-url origin)
SIMPLESAMLPHP_VERSION := $(shell cat .simplesamlphp_version)
REGISTRY_HOST         := $(REGISTRY_HOST)
USER                  := $(DOCKERHUB_USERNAME)
IMAGE                 := $(REGISTRY_HOST)/$(USER)/$(NAME)
RELEASE_TAGS          := $(SIMPLESAMLPHP_VERSION) latest

.PHONY: build
build:
	docker build \
		--build-arg GIT_REVISION="$(REVISION)" \
		--build-arg GIT_ORIGIN="$(ORIGIN)" \
		--build-arg IMAGE_NAME="$(IMAGE)" \
		--build-arg SIMPLESAMLPHP_VERSION="$(SIMPLESAMLPHP_VERSION)" \
		$(addprefix -t $(IMAGE):,$(RELEASE_TAGS)) .

.PHONY: push
push:
	@for TAG in $(RELEASE_TAGS); do\
        docker push $(IMAGE):$$TAG; \
    done
