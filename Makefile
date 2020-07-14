PACK_CMD?=pack

GIT_TAG := $(shell git tag --points-at HEAD)
VERSION_TAG := $(shell [ -z $(GIT_TAG) ] && echo 'tip' || echo $(GIT_TAG) )

BASE_REPO  := quay.io/boson/faas-stack-base
BUILD_REPO := quay.io/boson/faas-stack-build
RUN_REPO   := quay.io/boson/faas-stack-run

QUARKUS_BUILDER_REPO := quay.io/boson/faas-quarkus-builder
NODEJS_BUILDER_REPO  := quay.io/boson/faas-nodejs-builder
GO_BUILDER_REPO      := quay.io/boson/faas-go-builder

QUARKUS_BUILDPACK_REPO := quay.io/boson/faas-quarkus-bp
NODEJS_BUILDPACK_REPO  := quay.io/boson/faas-nodejs-bp
GO_BUILDPACK_REPO      := quay.io/boson/faas-go-bp

.PHONY: stacks buildpacks builders

all: stacks buildpacks builders

stacks:
	./stacks/build-stack.sh stacks/ubi8
	./stacks/build-stack.sh stacks/ubi8-minimal
	./stacks/build-stack.sh stacks/nodejs
	./stacks/build-stack.sh stacks/quarkus
	./stacks/build-stack.sh stacks/go

buildpacks:
	$(PACK_CMD) package-buildpack $(NODEJS_BUILDPACK_REPO):$(VERSION_TAG) --package-config ./packages/nodejs/package.toml
	$(PACK_CMD) package-buildpack $(QUARKUS_BUILDPACK_REPO):$(VERSION_TAG) --package-config ./packages/quarkus/package.toml
	$(PACK_CMD) package-buildpack $(GO_BUILDPACK_REPO):$(VERSION_TAG) --package-config ./packages/go/package.toml

builders:
	$(PACK_CMD) create-builder $(NODEJS_BUILDER_REPO):$(VERSION_TAG) --builder-config ./builders/nodejs/builder.toml
	$(PACK_CMD) create-builder $(QUARKUS_BUILDER_REPO):$(VERSION_TAG) --builder-config ./builders/quarkus/builder.toml
	$(PACK_CMD) create-builder $(GO_BUILDER_REPO):$(VERSION_TAG) --builder-config ./builders/go/builder.toml

publish:
	docker push $(BASE_REPO):ubi8-minimal
	docker push $(BASE_REPO):ubi8

	docker push $(BUILD_REPO):ubi8-minimal
	docker push $(BUILD_REPO):ubi8
	docker push $(BUILD_REPO):go
	docker push $(BUILD_REPO):quarkus
	docker push $(BUILD_REPO):nodejs

	docker push $(RUN_REPO):go
	docker push $(RUN_REPO):quarkus
	docker push $(RUN_REPO):nodejs
	docker push $(RUN_REPO):ubi8-minimal
	docker push $(RUN_REPO):ubi8

	docker push $(QUARKUS_BUILDPACK_REPO):$(VERSION_TAG)
	docker push $(NODEJS_BUILDPACK_REPO):$(VERSION_TAG)
	docker push $(GO_BUILDPACK_REPO):$(VERSION_TAG)

	docker push $(QUARKUS_BUILDER_REPO):$(VERSION_TAG)
	docker push $(NODEJS_BUILDER_REPO):$(VERSION_TAG)
	docker push $(GO_BUILDER_REPO):$(VERSION_TAG)
