PACK_CMD?=pack

GIT_TAG := $(shell git tag --points-at HEAD)
VERSION_TAG := $(shell [ -z $(GIT_TAG) ] && echo 'tip' || echo $(GIT_TAG) )

BASE_REPO  := quay.io/boson/faas-stack-base
BUILD_REPO := quay.io/boson/faas-stack-build
RUN_REPO   := quay.io/boson/faas-stack-run

NODEJS_BUILDER_REPO  := quay.io/boson/faas-nodejs-builder
GO_BUILDER_REPO      := quay.io/boson/faas-go-builder
QUARKUS_JVM_BUILDER_REPO := quay.io/boson/faas-quarkus-jvm-builder
QUARKUS_NATIVE_BUILDER_REPO := quay.io/boson/faas-quarkus-native-builder
SPRINGBOOT_BUILDER_REPO := quay.io/boson/faas-springboot-builder
PYTHON_BUILDER_REPO := quay.io/boson/faas-python-builder

NODEJS_BUILDPACK_REPO  := quay.io/boson/faas-nodejs-bp
GO_BUILDPACK_REPO      := quay.io/boson/faas-go-bp
QUARKUS_JVM_BUILDPACK_REPO := quay.io/boson/faas-quarkus-jvm-bp
QUARKUS_NATIVE_BUILDPACK_REPO := quay.io/boson/faas-quarkus-native-bp
SPRINGBOOT_BUILDPACK_REPO := quay.io/boson/faas-springboot-bp
PYTHON_BUILDPACK_REPO := quay.io/boson/faas-python-bp


.PHONY: stacks buildpacks builders

all: stacks buildpacks builders

stacks:
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/ubi8
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/ubi8-minimal
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/nodejs
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/go
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/quarkus-jvm
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/quarkus-native
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/springboot
	./stacks/build-stack.sh -v $(VERSION_TAG) stacks/python

buildpacks:
	$(PACK_CMD) package-buildpack $(NODEJS_BUILDPACK_REPO):$(VERSION_TAG) --config ./packages/nodejs/package.toml
	$(PACK_CMD) package-buildpack $(GO_BUILDPACK_REPO):$(VERSION_TAG) --config ./packages/go/package.toml
	$(PACK_CMD) package-buildpack $(QUARKUS_JVM_BUILDPACK_REPO):$(VERSION_TAG) --config ./packages/quarkus-jvm/package.toml
	$(PACK_CMD) package-buildpack $(QUARKUS_NATIVE_BUILDPACK_REPO):$(VERSION_TAG) --config ./packages/quarkus-native/package.toml
	$(PACK_CMD) package-buildpack $(SPRINGBOOT_BUILDPACK_REPO):$(VERSION_TAG) --config ./packages/springboot/package.toml
	$(PACK_CMD) package-buildpack $(PYTHON_BUILDPACK_REPO):$(VERSION_TAG) --config ./packages/python/package.toml

builders:
	TMP_BLDRS=$(shell mktemp -d) && \
	sed "s/{{VERSION}}/$(VERSION_TAG)/g" ./builders/nodejs/builder.toml > $$TMP_BLDRS/node.toml && \
	sed "s/{{VERSION}}/$(VERSION_TAG)/g" ./builders/quarkus-native/builder.toml > $$TMP_BLDRS/quarkus-native.toml && \
	sed "s/{{VERSION}}/$(VERSION_TAG)/g" ./builders/go/builder.toml > $$TMP_BLDRS/go.toml && \
	sed "s/{{VERSION}}/$(VERSION_TAG)/g" ./builders/quarkus-jvm/builder.toml > $$TMP_BLDRS/quarkus-jvm.toml && \
	sed "s/{{VERSION}}/$(VERSION_TAG)/g" ./builders/springboot/builder.toml > $$TMP_BLDRS/springboot.toml && \
	sed "s/{{VERSION}}/$(VERSION_TAG)/g" ./builders/python/builder.toml > $$TMP_BLDRS/python.toml && \
	$(PACK_CMD) create-builder --pull-policy=never $(NODEJS_BUILDER_REPO):$(VERSION_TAG) --config $$TMP_BLDRS/node.toml && \
	$(PACK_CMD) create-builder --pull-policy=never $(GO_BUILDER_REPO):$(VERSION_TAG) --config $$TMP_BLDRS/go.toml && \
	$(PACK_CMD) create-builder --pull-policy=never $(QUARKUS_JVM_BUILDER_REPO):$(VERSION_TAG) --config $$TMP_BLDRS/quarkus-jvm.toml && \
	$(PACK_CMD) create-builder --pull-policy=never $(QUARKUS_NATIVE_BUILDER_REPO):$(VERSION_TAG) --config $$TMP_BLDRS/quarkus-native.toml && \
	$(PACK_CMD) create-builder --pull-policy=never $(SPRINGBOOT_BUILDER_REPO):$(VERSION_TAG) --config $$TMP_BLDRS/springboot.toml -v && \
	$(PACK_CMD) create-builder --pull-policy=never $(PYTHON_BUILDER_REPO):$(VERSION_TAG) --config $$TMP_BLDRS/python.toml -v && \
	rm -fr $$TMP_BLDRS

publish:
	docker push $(BASE_REPO):ubi8-minimal-$(VERSION_TAG)
	docker push $(BASE_REPO):ubi8-$(VERSION_TAG)

	for i in go quarkus-native quarkus-jvm nodejs springboot ubi8-minimal ubi8; do \
	    docker push $(RUN_REPO):$$i-$(VERSION_TAG); \
	    docker push $(BUILD_REPO):$$i-$(VERSION_TAG); \
	done

	for img in $(QUARKUS_NATIVE_BUILDPACK_REPO) $(QUARKUS_JVM_BUILDPACK_REPO) $(QUARKUS_NATIVE_BUILDER_REPO) $(QUARKUS_JVM_BUILDER_REPO) $(NODEJS_BUILDPACK_REPO) $(GO_BUILDPACK_REPO) $(NODEJS_BUILDER_REPO) $(GO_BUILDER_REPO) $(SPRINGBOOT_BUILDPACK_REPO) $(SPRINGBOOT_BUILDER_REPO) $(PYTHON_BUILDPACK_REPO) $(PYTHON_BUILDER_REPO); do \
		docker push $$img:$(VERSION_TAG); \
		if [ "$(VERSION_TAG)" != "tip" ]; then \
		    docker tag $$img:$(VERSION_TAG) $$img:latest; \
		    docker push $$img:latest; \
		fi \
	done
