#!/usr/bin/env bash

set -e

install_or_reuse_deps() {
  local layer_dir=$1
  local requirements=$2
  local env_dir="${layer_dir}/functions"

  touch "${layer_dir}.toml"
  mkdir -p ${layer_dir}

  echo "Using python version $(python3 --version)"
  
  if [[ ! -d ${env_dir} ]]; then
    echo "Installing invoker dependencies"
    cd ${layer_dir}
    echo "Installing virtualenv"
    pip3 install --user virtualenv
    echo "Creating functions runtime environment"
    python3 -m venv functions
    echo "Activating functions environment"
    source functions/bin/activate
    echo "Installing flask"
    pip3 install flask
    echo "Installing waitress"
    pip3 install waitress
    echo "Installing cloudevents"
    pip3 install cloudevents
  fi

  if [ -f ${requirements} ] ; then
    echo "Installing user dependencies"
    source ${layer_dir}/functions/bin/activate
    pip3 install -r ${requirements}
  fi

  echo "cache = true" > "${layer_dir}.toml"
  echo "build = true" >> "${layer_dir}.toml"
  echo "launch = true" >> "${layer_dir}.toml"
}
