NAME                  := $(shell basename $(CURDIR) | sed -e "s/^docker-//g")
REVISION              := $(shell git rev-parse --short HEAD)
ORIGIN                := $(shell git remote get-url origin)
SIMPLESAMLPHP_VERSION := $(shell cat .simplesamlphp_version)
REGISTRY_HOST         ?= index.docker.io
REGISTRY_USERNAME     ?= defaultusername
IMAGE                 := $(REGISTRY_HOST)/$(REGISTRY_USERNAME)/$(NAME)
RELEASE_TAGS          := $(SIMPLESAMLPHP_VERSION) latest

.PHONY: release
release: ## build and push docker images. e.g.) make release
	docker buildx build \
		--push \
		--platform linux/amd64,linux/arm64 \
		--build-arg GIT_REVISION="$(REVISION)" \
		--build-arg GIT_ORIGIN="$(ORIGIN)" \
		--build-arg IMAGE_NAME="$(IMAGE)" \
		--build-arg SIMPLESAMLPHP_VERSION="$(SIMPLESAMLPHP_VERSION)" \
		$(addprefix -t $(IMAGE):,$(RELEASE_TAGS)) .

.PHONY: build
build: ## build a docker image. e.g.) make build PLATFORM=linux/amd64
	docker buildx build \
		--load \
		--platform "$(PLATFORM)" \
		--build-arg GIT_REVISION="$(REVISION)" \
		--build-arg GIT_ORIGIN="$(ORIGIN)" \
		--build-arg IMAGE_NAME="$(IMAGE)" \
		--build-arg SIMPLESAMLPHP_VERSION="$(SIMPLESAMLPHP_VERSION)" \
		$(addprefix -t $(IMAGE):,$(RELEASE_TAGS)) .

.PHONY: test
test: ## test a docker image. e.g.) make test PLATFORM=linux/amd64
	dgoss run \
		--rm \
		--platform "$(PLATFORM)" \
		-e SIMPLESAMLPHP_SP_ENTITY_ID=http://app.example.com \
		-e SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE=http://localhost/simplesaml/module.php/saml/sp/saml2-acs.php/test-sp \
		-e SIMPLESAMLPHP_SP_SINGLE_LOGOUT_SERVICE=http://localhost/simplesaml/module.php/saml/sp/saml2-logout.php/test-sp \
		"$(IMAGE)"
