# Changelog

### [0.5.2](https://www.github.com/boson-project/buildpacks/compare/v0.5.1...v0.5.2) (2021-02-19)


### Bug Fixes

* publish missing springboot images ([#62](https://www.github.com/boson-project/buildpacks/issues/62)) ([8d0aaa8](https://www.github.com/boson-project/buildpacks/commit/8d0aaa8dd4d21722c7cbb28838341f98731cf2d4))

### [0.5.1](https://www.github.com/boson-project/buildpacks/compare/v0.5.0...v0.5.1) (2021-02-04)


### Bug Fixes

* change buildpack, builder and stack ids ([#47](https://www.github.com/boson-project/buildpacks/issues/47)) ([5057386](https://www.github.com/boson-project/buildpacks/commit/50573860d262f7c1685d5283288722f2f5f4bc29))

## [0.5.0](https://www.github.com/boson-project/buildpacks/compare/v0.4.1...v0.5.0) (2020-11-26)


### Features

* add springboot buildpack/builder ([#46](https://www.github.com/boson-project/buildpacks/issues/46)) ([141f6c5](https://www.github.com/boson-project/buildpacks/commit/141f6c53a916b3bc41bc4e0fd639c18626ca3d85)), closes [#45](https://www.github.com/boson-project/buildpacks/issues/45)


### Bug Fixes

* add --nodocs to dnf install to reduce image size ([#50](https://www.github.com/boson-project/buildpacks/issues/50)) ([7ec6d04](https://www.github.com/boson-project/buildpacks/commit/7ec6d04e3a90ece91a368824e0d8ac7824c9aee6))
* don't assume /workspace in go builder ([#53](https://www.github.com/boson-project/buildpacks/issues/53)) ([d642ab5](https://www.github.com/boson-project/buildpacks/commit/d642ab50bb363442969753272beb0dd408b771ae))

### [0.4.1](https://www.github.com/boson-project/buildpacks/compare/v0.4.0...v0.4.1) (2020-11-17)


### Bug Fixes

* **deps:** sync node.js builder with faas CLI ([#43](https://www.github.com/boson-project/buildpacks/issues/43)) ([f441ea2](https://www.github.com/boson-project/buildpacks/commit/f441ea227cdbacb03e081b49d30edcda1301843d))

## [0.4.0](https://www.github.com/boson-project/buildpacks/compare/v0.3.2...v0.4.0) (2020-10-14)


### Features

* add health liveness and readiness endpoints to go buildpack ([#34](https://www.github.com/boson-project/buildpacks/issues/34)) ([105470d](https://www.github.com/boson-project/buildpacks/commit/105470db93f200e23f63a46f034ed1de06ed0c97))

## [0.3.0](https://www.github.com/boson-project/buildpacks/compare/v0.2.3...v0.3.0) (2020-09-29)


### Features

* JVM mode builds for Quarkus ([ba10da7](https://www.github.com/boson-project/buildpacks/commit/ba10da7eb9d9db9c0d21d0722083fe439d282de3))
* recover from panic in user function ([090ceb4](https://www.github.com/boson-project/buildpacks/commit/090ceb48fe6fc118a14eebe81b4fb89775e0e1a9))
* **ci/cd:** add automated releases with release-please ([#24](https://www.github.com/boson-project/buildpacks/issues/24)) ([4ac12b7](https://www.github.com/boson-project/buildpacks/commit/4ac12b7029e92030704e5112009445fd62f2a586))

## [0.2.3](https://www.github.com/boson-project/buildpacks/compare/v0.1.0...v0.2.3) (2020-09-09)


### Features

 raw HTTP support for Go [41477eb](https://github.com/boson-project/buildpacks/commit/41477eb15a85755c803181b21bc20dcb8fdc8ddf)

 ### Bug Fixes

return failure code for failed detection (#21) [90ffd0e](https://github.com/boson-project/buildpacks/commit/90ffd0e32b26318a924ce120d53550eb8bcbec41)
change stack images to be built on UBI 8.2 (#15) [7ca5602](https://github.com/boson-project/buildpacks/commit/7ca5602c15ba6b6e091b2d87e137a08ec026865a)
standard shell syntax (#13) [2fe2ec6](https://github.com/boson-project/buildpacks/commit/2fe2ec69793c58c136ec14133c987596f8229d14)
correct tagging for `latest` (#12) [ca49148](https://github.com/boson-project/buildpacks/commit/ca491489233c6b0a1481e214b2bc1a850681ec8a)

### Documentation

update README.md to point builder at quay.io [180a498](https://github.com/boson-project/buildpacks/commit/180a498ddf22e126842afe201b79168a28f8fb8a)
