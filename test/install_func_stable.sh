#!/usr/bin/env bash

set -e
set -o pipefail

WD="$(pwd)"

mkdir -p "$WD/bin/"

# install latest official release
curl -L -o - https://github.com/boson-project/func/releases/latest/download/func_linux_amd64.gz | gunzip > "$WD/bin/func_stable"
chmod 755 "$WD/bin/func_stable"
