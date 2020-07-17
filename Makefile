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
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/ubi8
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/ubi8-minimal
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/nodejs
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/quarkus
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/go

buildpacks:
	$(PACK_CMD) package-buildpack $(NODEJS_BUILDPACK_REPO):$(VERSION_TAG) --package-config ./packages/nodejs/package.toml
	$(PACK_CMD) package-buildpack $(QUARKUS_BUILDPACK_REPO):$(VERSION_TAG) --package-config ./packages/quarkus/package.toml
	$(PACK_CMD) package-buildpack $(GO_BUILDPACK_REPO):$(VERSION_TAG) --package-config ./packages/go/package.toml

builders:
	TMP_BLDRS=$(shell mktemp -d) && \
	sed "s/{{VERSION}}/$(VERSION_TAG)/g" ./builders/nodejs/builder.toml > $$TMP_BLDRS/node.toml && \
	sed "s/{{VERSION}}/$(VERSION_TAG)/g" ./builders/quarkus/builder.toml > $$TMP_BLDRS/quarkus.toml && \
	sed "s/{{VERSION}}/$(VERSION_TAG)/g" ./builders/go/builder.toml > $$TMP_BLDRS/go.toml && \
	$(PACK_CMD) create-builder $(NODEJS_BUILDER_REPO):$(VERSION_TAG) --builder-config $$TMP_BLDRS/node.toml && \
	$(PACK_CMD) create-builder $(QUARKUS_BUILDER_REPO):$(VERSION_TAG) --builder-config $$TMP_BLDRS/quarkus.toml && \
	$(PACK_CMD) create-builder $(GO_BUILDER_REPO):$(VERSION_TAG) --builder-config $$TMP_BLDRS/go.toml && \
	rm -fr $$TMP_BLDRS

publish:
	docker push $(BASE_REPO):ubi8-minimal-$(VERSION_TAG)
	docker push $(BASE_REPO):ubi8-$(VERSION_TAG)

	for i in go quarkus nodejs ubi8-minimal ubi8; do \
	    docker push $(RUN_REPO):$$i-$(VERSION_TAG); \
	    docker push $(BUILD_REPO):$$i-$(VERSION_TAG); \
	done

	if [[ "$(VERSION_TAG)" == "tip" ]]; then \
		versions="tip"; \
	else \
	  	versions="$(VERSION_TAG) latest"; \
	fi;\
	for img in $(QUARKUS_BUILDPACK_REPO) $(NODEJS_BUILDPACK_REPO) $(GO_BUILDPACK_REPO) $(QUARKUS_BUILDER_REPO) $(NODEJS_BUILDER_REPO) $(GO_BUILDER_REPO); do \
		for v in $$versions; do \
			docker push $$img:$$v; \
		done \
	done
