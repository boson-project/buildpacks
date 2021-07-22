#!/usr/bin/env bash

set -euo pipefail
set -o xtrace

VERSION="${2-tip}"
REPOSITORY="quay.io/boson"
PACK_CMD=${PACK_CMD:-pack}

STACKS=(ubi8 go python nodejs quarkus-native rust jvm)
BUILD_PACKS=(go nodejs python quarkus-jvm quarkus-native springboot rust)
BUILDERS=(go nodejs python jvm quarkus-native rust)

stack_to_run_img() {
    local TAG="${1}-${2}"
    echo "${REPOSITORY}/faas-stack-run:${TAG}"
}

stack_to_build_img() {
    local TAG="${1}-${2}"
    echo "${REPOSITORY}/faas-stack-build:${TAG}"
}

buildpack_to_img() { echo "${REPOSITORY}/faas-${1}-bp:${2}"; }

builder_to_img() { echo "${REPOSITORY}/faas-${1}-builder:${2}"; }

make_stacks() {
  for STACK in "${STACKS[@]}"; do
    local STACK_ID="dev.boson.stacks.${STACK}"
    docker build "stacks/${STACK}/build/" \
      --build-arg "stack_id=${STACK_ID}" \
      --build-arg "version=${VERSION}" \
      -t "$(stack_to_build_img "${STACK}" "${VERSION}")"
    docker build "stacks/${STACK}/run/" \
      --build-arg "stack_id=${STACK_ID}" \
      --build-arg "version=${VERSION}" \
      -t "$(stack_to_run_img "${STACK}" "${VERSION}")"
  done
}

make_buildpacks() {
  for BUILD_PACK in "${BUILD_PACKS[@]}"; do
    local BP_PATH="./buildpacks/${BUILD_PACK}/"
    $PACK_CMD buildpack package "$(buildpack_to_img "${BUILD_PACK}" "${VERSION}")" \
    --path "${BP_PATH}"
  done
}

make_builders() {
  local TMP_DIR
  TMP_DIR=$(mktemp -d)
  # shellcheck disable=SC2064
  trap "rm -fr ${TMP_DIR}" EXIT
  for BUILDER in "${BUILDERS[@]}"; do
    sed "s/{{VERSION}}/${VERSION}/g" "./builders/${BUILDER}/builder.toml" > \
      "$TMP_DIR/${BUILDER}.toml"
    ${PACK_CMD} builder create --pull-policy=never \
      "$(builder_to_img "${BUILDER}" "${VERSION}")" \
      --config "$TMP_DIR/${BUILDER}.toml"
  done
}

make_publish() {
  local TO_PUSH=()
  for STACK in "${STACKS[@]}"; do
    TO_PUSH+=("$(stack_to_run_img "${STACK}" "${VERSION}")")
    TO_PUSH+=("$(stack_to_build_img "${STACK}" "${VERSION}")")
  done
  for BUILD_PACK in "${BUILD_PACKS[@]}"; do
    TO_PUSH+=("$(buildpack_to_img "${BUILD_PACK}" "${VERSION}")")
  done
  for BUILDER in "${BUILDERS[@]}"; do
    TO_PUSH+=("$(builder_to_img "${BUILDER}" "${VERSION}")")
  done

  if [[ "${VERSION}" != "tip" ]]; then
    for BUILDER in "${BUILDERS[@]}"; do
      TO_PUSH+=("$(builder_to_img "${BUILDER}" "latest")")
    done
  fi

  for IMG in "${TO_PUSH[@]}"; do
    docker push "${IMG}"
  done
}

case $1 in
  "stacks")
    make_stacks
    ;;
  "buildpacks")
    make_buildpacks
    ;;
  "builders")
    make_builders
    ;;
  "publish")
  make_publish
  ;;
  *)
    echo "invalid command"
    exit 1
    ;;
esac