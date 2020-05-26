#!/usr/bin/env bash

set -e

detect_package_lock() {
  local build_dir=$1
  [[ -f "$build_dir/package-lock.json" ]]
}

detect_package_json() {
  local build_dir=$1
  [[ -f "$build_dir/package.json" ]]
}

detect_function() {
  local build_dir=$1
  [[ -f "$build_dir/index.js" ]]
}

log_info() {
  echo "---> $1"
}