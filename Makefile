PACK_CMD?=pack

GIT_TAG := $(shell git tag --points-at HEAD)
VERSION_TAG := $(shell [ -z $(GIT_TAG) ] && echo 'tip' || echo $(GIT_TAG) )

.PHONY: stacks buildpacks builders test

all: stacks buildpacks builders

stacks:
	./hack/make.sh stacks $(VERSION_TAG)

buildpacks:
	./hack/make.sh buildpacks $(VERSION_TAG)

builders:
	./hack/make.sh builders $(VERSION_TAG)

bin/func_stable:
	test/install_func_stable.sh

bin/func_snapshot:
	test/install_func_snapshot.sh

test: bin/func_stable bin/func_snapshot
	test/test_builders.go $(VERSION_TAG)

publish:
	./hack/make.sh publish $(VERSION_TAG)

clean:
	rm bin/*
