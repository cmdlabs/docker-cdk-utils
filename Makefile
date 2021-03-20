IMAGE_NAME ?= cmdlabs/cdk-utils

RELEASE_VERSION = 1.1.0
BUILD_VERSION ?= testing

ifdef CI_COMMIT_REF_NAME
	BUILD_VERSION=$(CI_COMMIT_REF_NAME)
endif

#Workaround for linux not supporting docker.host.internal
UNAME = $(shell uname)
ifeq ($(UNAME), Linux)
	HOSTIP = --add-host=host.docker.internal:$(shell ip route | grep docker0 | awk '{print $$9}')
endif

login:
	docker login -u $(DOCKER_HUB_CMDSOLUTIONS_USER) -p $(DOCKER_HUB_CMDSOLUTIONS_PASS)
PHONY: login

build:
	docker build -t $(IMAGE_NAME):$(BUILD_VERSION) .
PHONY: build

test:
	docker run --rm --entrypoint=cdk $(IMAGE_NAME):$(BUILD_VERSION) --version
	docker run --rm --entrypoint=aws $(IMAGE_NAME):$(BUILD_VERSION) --version
	@echo "All tests completed successfully"
PHONY: test

scan:
	docker run --rm -d --name clair-db arminc/clair-db:latest
	docker run --rm $(HOSTIP) -p 6060:6060 --link clair-db:postgres -d --name clair arminc/clair-local-scan:latest
	clair-scanner --ip host.docker.internal $(IMAGE_NAME):$(BUILD_VERSION)
.PHONY: scan

scanClean:
	docker stop clair-db; true
	docker stop clair; true
.PHONY: scanClean

push: login
	docker push $(IMAGE_NAME):$(BUILD_VERSION)
.PHONY: push

pushLatest: login
	docker pull $(IMAGE_NAME):$(BUILD_VERSION)
	docker tag $(IMAGE_NAME):$(BUILD_VERSION) $(IMAGE_NAME):latest
	docker push $(IMAGE_NAME):latest
.PHONY: tagLatest

tag:
	git tag -a $(RELEASE_VERSION) -m ''
	git push origin $(RELEASE_VERSION)
PHONY: tag

publish:
	git fetch --all
	git remote add github https://$(GIT_USERNAME):$(GIT_PASSWORD)@github.com/cmdlabs/$(CI_PROJECT_NAME)
	git checkout master
	git pull origin master
	git push --follow-tags github master
	curl -X POST -H 'Content-type: application/json' --data '{"text":"A new commit has been published to Github\nProject: $(CI_PROJECT_NAME)\nRef: $(CI_COMMIT_REF_NAME)\nDiff: https://github.com/cmdlabs/$(CI_PROJECT_NAME)/commit/$(CI_COMMIT_SHA)"}' $(GIT_PUBLISHING_WEBHOOK)
PHONY: publish
