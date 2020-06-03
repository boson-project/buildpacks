.PHONY: build-stacks build-buildpacks build-builder

all: build-stacks build-buildpacks build-builder

build-stacks:
	./stacks/build-stack.sh stacks/ubi8
	./stacks/build-stack.sh stacks/ubi8-minimal
	./stacks/build-stack.sh stacks/nodejs
	./stacks/build-stack.sh stacks/quarkus

build-buildpacks:
	pack package-buildpack bosonproject/faas-nodejs-bp --package-config ./packages/nodejs/package.toml
	pack package-buildpack bosonproject/faas-quarkus-bp --package-config ./packages/quarkus/package.toml

build-builder:
	pack create-builder bosonproject/faas-nodejs-builder --builder-config ./builders/nodejs/builder.toml
	pack create-builder bosonproject/faas-quarkus-builder --builder-config ./builders/quarkus/builder.toml
