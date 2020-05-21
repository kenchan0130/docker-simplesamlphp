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

.PHONY: test
test:
	dgoss run \
		-e SIMPLESAMLPHP_SP_ENTITY_ID=http://app.example.com \
  		-e SIMPLESAMLPHP_SP_ASSERTION_CONSUMER_SERVICE=http://localhost/simplesaml/module.php/saml/sp/saml2-acs.php/test-sp \
  		-e SIMPLESAMLPHP_SP_SINGLE_LOGOUT_SERVICE=http://localhost/simplesaml/module.php/saml/sp/saml2-logout.php/test-sp \
		"$(USER)/$(NAME)"

.PHONY: push
push:
	@for TAG in $(RELEASE_TAGS); do\
        docker push $(IMAGE):$$TAG; \
    done
