#!/usr/bin/env bash
# ./Scripts/install-swiftprotobuf.sh
# Clones apple/swift-protobuf (if missing), checks out a specific version, and builds a release.

set -euo pipefail

# ===== Settings =====
# Set the desired release tag here (examples: 1.26.0, 1.25.2). No env override.
SWIFT_PROTOBUF_VERSION="1.32.0"
REPO_URL="https://github.com/apple/swift-protobuf"

# Project root = one level above Scripts/
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# Clone destination
BUILD_DIR="${ROOT_DIR}/build"
CLONE_DIR="${BUILD_DIR}/swift-protobuf"

# ===== Clone (if needed) =====
mkdir -p "${BUILD_DIR}"

if [ ! -d "${CLONE_DIR}/.git" ]; then
  echo "➡️  Cloning ${REPO_URL} into ${CLONE_DIR}..."
  git clone "${REPO_URL}" "${CLONE_DIR}"
else
  echo "ℹ️  Repository already exists at ${CLONE_DIR}."
fi

# ===== Fetch tags and checkout version =====
echo "➡️  Fetching tags..."
git -C "${CLONE_DIR}" fetch --all --tags --prune

pushd "${CLONE_DIR}" >/dev/null

# Support tags with and without 'v' prefix
if git rev-parse -q --verify "refs/tags/${SWIFT_PROTOBUF_VERSION}" >/dev/null; then
  TAG="refs/tags/${SWIFT_PROTOBUF_VERSION}"
elif git rev-parse -q --verify "refs/tags/v${SWIFT_PROTOBUF_VERSION}" >/dev/null; then
  TAG="refs/tags/v${SWIFT_PROTOBUF_VERSION}"
else
  echo "❌ Tag ${SWIFT_PROTOBUF_VERSION} (or v${SWIFT_PROTOBUF_VERSION}) not found in ${REPO_URL}." >&2
  echo "   Tip: list available versions with:  git -C ${CLONE_DIR} tag -l" >&2
  exit 1
fi

echo "➡️  Checking out ${TAG}..."
git checkout -q "${TAG}"
git submodule update --init --recursive

# ===== Build (release) =====
echo "➡️  Building (SwiftPM, release)..."
swift build -c release

popd >/dev/null

# ===== Done =====
echo "✅ Done."
echo "   Repository: ${CLONE_DIR}"
echo "   Build dir:  ${CLONE_DIR}/.build/release"
echo "   Version:    ${SWIFT_PROTOBUF_VERSION}"