NAME          := $(shell basename $(CURDIR) | sed -e "s/^docker-//g")
REVISION      := $(shell git rev-parse --short HEAD)
ORIGIN        := $(shell git remote get-url origin)
LATEST_TAG    := $(shell git describe --abbrev=0 --tags)
TAG_REVISION  := $(shell git rev-parse --short $(LATEST_TAG))
REGISTRY_HOST := $(REGISTRY_HOST)
USER          := $(DOCKERHUB_USERNAME)
IMAGE         := $(REGISTRY_HOST)/$(USER)/$(NAME)
RELEASE_TAGS  := $(shell test "$(REVISION)" = "$(TAG_REVISION)" && echo $(LATEST_TAG) latest || echo latest)

.PHONY: build
build:
	docker build \
		--build-arg GIT_REVISION="$(REVISION)" \
		--build-arg GIT_ORIGIN="$(ORIGIN)" \
		--build-arg IMAGE_NAME="$(IMAGE)" \
		--build-arg SIMPLESAMLPHP_VERSION="$(LATEST_TAG)" \
		$(addprefix -t $(IMAGE):,$(RELEASE_TAGS)) .

.PHONY: push
push:
	@for TAG in $(RELEASE_TAGS); do\
        docker push $(IMAGE):$$TAG; \
    done
