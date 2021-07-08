#!/usr/bin/env bash

set -e

bp_dir=$(cd "$(dirname "$BASH_SOURCE")"; cd ..; pwd)
source "${bp_dir}/lib/util.sh"

install() {
  local build_dir=$1
  local layer_dir=$2

  log_info "Installing function in ${layer_dir}"
  mkdir -p $layer_dir

  rm func.yaml
  cp -r "$build_dir"/* $layer_dir
  cp -r "$build_dir"/.invoker $layer_dir
  rm -rf "$build_dir"/* "$build_dir"/.*
  
  echo "cache = false" > "${layer_dir}.toml"
  echo "build = false" >> "${layer_dir}.toml"
  echo "launch = true" >> "${layer_dir}.toml"
}

install_or_reuse_tools() {
  local layer_dir=$1
  touch "${layer_dir}.toml"

  log_info "Installing tools"
  mkdir -p "${layer_dir}/bin"

  if [[ ! -f "${layer_dir}/bin/jq" ]]; then
    log_info "- jq"
    curl -Ls https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 > "${layer_dir}/bin/jq" \
      && chmod +x "${layer_dir}/bin/jq"
  fi

  if [[ ! -f "${layer_dir}/bin/yj" ]]; then
    log_info "- yj"
    curl -Ls https://github.com/sclevine/yj/releases/download/v2.0/yj-linux > "${layer_dir}/bin/yj" \
      && chmod +x "${layer_dir}/bin/yj"
  fi

  echo "cache = true" > "${layer_dir}.toml"
  echo "build = true" >> "${layer_dir}.toml"
  echo "launch = false" >> "${layer_dir}.toml"
}

install_invoker() {
  local bp_dir=$1
  local build_dir=$2
  local layer_dir=$3

  touch "$layer_dir.toml"
  mkdir -p "${layer_dir}"

  # copy invoker source to the build directory
  log_info "Installing function invoker"
  mkdir -p ${build_dir}
  cp ${bp_dir}/runtime/package*.json ${bp_dir}/runtime/server.js ${build_dir}
  install_or_reuse_node_modules ${build_dir} ${layer_dir}
}

install_modules() {
  local build_dir=$1
  log_info "Installing node modules in ${build_dir}"
  if detect_package_lock "$build_dir" ; then
    log_info "From ./package-lock.json"
    npm ci
  else
    npm install --production
  fi
}

install_or_reuse_node_modules() {
  local build_dir=$1
  local layer_dir=$2
  local local_lock_checksum
  local cached_lock_checksum

  if ! detect_package_lock "$build_dir" ; then
    install_modules "$build_dir"
  fi

  touch "$layer_dir.toml"
  mkdir -p "${layer_dir}"

  local_lock_checksum=$(sha256sum "$build_dir/package-lock.json" | cut -d " " -f 1)
  cached_lock_checksum=$(yj -t < "${layer_dir}.toml" | jq -r ".metadata.package_lock_checksum")

  if [[ "$local_lock_checksum" == "$cached_lock_checksum" ]] ; then
      log_info "Reusing cached node modules in ${layer_dir}"
      cp -r "$layer_dir" "$build_dir/node_modules"
  else
    echo "cache = true" > "${layer_dir}.toml"

    {
      echo "build = false"
      echo "launch = false"
      echo -e "[metadata]\npackage_lock_checksum = \"$local_lock_checksum\""
    } >> "${layer_dir}.toml"

    install_modules "$build_dir"

    if [[ -d "$build_dir/node_modules" && -n "$(ls -A "$build_dir/node_modules")" ]] ; then
      cp -r "$build_dir/node_modules/." "$layer_dir"
    fi
  fi
}
