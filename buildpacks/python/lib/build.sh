#!/usr/bin/env bash

set -e

install_or_reuse_deps() {
  echo "Installing function invoker dependencies"
  local layer_dir=$1
  local env_dir="${layer_dir}/functions"

  touch "${layer_dir}.toml"
  mkdir -p ${layer_dir}

  echo "Using python version $(python3 --version)"
  
  if [[ ! -d ${env_dir} ]]; then
    cd ${layer_dir}
    echo "Installing virtualenv"
    pip3 install --user virtualenv
    echo "Creating function runtime environment"
    python3 -m venv functions
    echo "Initializing functions environment"
    source functions/bin/activate
    echo "Installing flask"
    pip3 install flask
    echo "Installing cloudevents"
    pip3 install cloudevents
  fi

  echo "cache = true" > "${layer_dir}.toml"
  echo "build = true" >> "${layer_dir}.toml"
  echo "launch = true" >> "${layer_dir}.toml"
}
