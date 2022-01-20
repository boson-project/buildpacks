#!/usr/bin/env bash

set -e
set -o pipefail

WD="$(pwd)"

mkdir -p "$WD/bin/"

# install latest from main branch
TMP_DIR="$(mktemp -d)"
cd "$TMP_DIR"
go get github.com/markbates/pkger/cmd/pkger
git clone https://github.com/knative-sandbox/kn-plugin-func
cd kn-plugin-func
make
cp func "$WD/bin/func_snapshot"
cd "$WD"
rm -fr "$TMP_DIR"
