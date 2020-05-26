.PHONY: build-stacks build-buildpacks build-builder

all: build-stacks build-buildpacks build-builder

build-stacks:
	./stacks/build-stack.sh stacks/ubi8
	./stacks/build-stack.sh stacks/ubi8-minimal
	./stacks/build-stack.sh stacks/nodejs

build-buildpacks:
	pack package-buildpack bosonproject/faas-nodejs-bp --package-config ./packages/nodejs/package.toml

build-builder:
	pack create-builder bosonproject/faas-nodejs-builder --builder-config ./builders/nodejs/builder.toml
