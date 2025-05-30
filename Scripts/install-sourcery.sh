#!/usr/bin/env bash

set -euo pipefail

# disable auto update sourcery

BUILD_DIR="./build"
BLOB_URL="https://github.com/krzysztofzablocki/Sourcery/releases/download/2.2.6/sourcery-2.2.6.zip"
TARBALL="${BUILD_DIR}/sourcery-2.2.6.zip"
EXTRACT_DIR="${BUILD_DIR}/sourcery-2.2.6"
SOURCERY_BIN="${BUILD_DIR}/sourcery"

mkdir -p "${BUILD_DIR}"

# remove existing files
if [[ -f "${TARBALL}" ]]; then
  rm -f "${TARBALL}"
fi

if [[ -d "${EXTRACT_DIR}" ]]; then
  rm -rf "${EXTRACT_DIR}"
fi

if [[ -f "${SOURCERY_BIN}" ]]; then
  rm -f "${SOURCERY_BIN}"
fi

# download bottle
curl -L "${BLOB_URL}" -o "${TARBALL}"

# extract archive
unzip "${TARBALL}" -d "${EXTRACT_DIR}"

# copy binary to build directory
cp "${EXTRACT_DIR}/bin/sourcery" "${SOURCERY_BIN}"

echo "Sourcery has been installed to ${SOURCERY_BIN}"
echo "To use it, run: ${SOURCERY_BIN}"