#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0
#
# Builds psycopg2_layer.zip — a Lambda layer providing psycopg2 for the
# python3.12 x86_64 runtime. Run before `terraform apply` in this directory.
# Requires python3 with pip.
set -euo pipefail
cd "$(dirname "$0")"

WORKDIR=$(mktemp -d)
trap 'rm -rf "$WORKDIR"' EXIT

python3 -m pip download psycopg2-binary \
  --platform manylinux2014_x86_64 \
  --python-version 3.12 \
  --only-binary=:all: \
  --dest "$WORKDIR" \
  --quiet

mkdir -p "$WORKDIR/python"
unzip -q "$WORKDIR"/psycopg2_binary-*.whl -d "$WORKDIR/python"
rm -f psycopg2_layer.zip
(cd "$WORKDIR" && zip -qr - python) > psycopg2_layer.zip
echo "Built $(pwd)/psycopg2_layer.zip"
