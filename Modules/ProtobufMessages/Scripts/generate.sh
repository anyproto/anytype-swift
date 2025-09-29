#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="${SCRIPT_DIR}/../../../"

# Generate models from protoc

protoc --plugin=protoc-gen-swift="${ROOT_DIR}/build/swift-protobuf/build/release" --swift_out="${ROOT_DIR}/Dependencies/Test" --proto_path="${ROOT_DIR}/Dependencies/Middleware/protobuf/protos" ${ROOT_DIR}/Dependencies/Middleware/protobuf/protos/*.proto

# ./Tools/SwiftGen/swiftgen config run --config ${SCRIPT_DIR}/Configs/swiftgen.yml
#./build/sourcery --config ${SCRIPT_DIR}/Loc/sourcery.yml
