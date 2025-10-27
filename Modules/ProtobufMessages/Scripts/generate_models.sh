#!/usr/bin/env bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MODULE_DIR=${SCRIPT_DIR}/..
ROOT_DIR=${SCRIPT_DIR}/../../..

# Generate models from protoc

PROTO_PATH=${ROOT_DIR}/Dependencies/Middleware/protobuf/protos
PROTO_OUT=${ROOT_DIR}/Dependencies/Middleware/genmodels

mkdir -p ${PROTO_OUT}
rm -rf ${PROTO_OUT}/*

find "$PROTO_PATH" -name '*.proto' | while read -r file; do
  # import "some/models.proto" -> import "models.proto"
  sed -i.bak -E \
    '/import[[:space:]]+"google\/protobuf\//! s#(import[[:space:]]+")([^"/]+/)*([^"/]+\.proto)"#\1\3"#g' \
    "$file"
done

protoc --plugin=protoc-gen-swift="${ROOT_DIR}/build/swift-protobuf/.build/release/protoc-gen-swift" --swift_opt=FileNaming=DropPath --swift_opt=Visibility=Public --swift_out="${PROTO_OUT}" --proto_path="${PROTO_PATH}" ${PROTO_PATH}/*.proto

# Split files and copy

rm -rf ${MODULE_DIR}/Sources/Protocol/*
./build/anytype-swift-filesplit-v1 --path ${PROTO_OUT}/commands.pb.swift --output-dir ${MODULE_DIR}/Sources/Protocol/Commands --other-name CommandsOther.swift
./build/anytype-swift-filesplit-v1 --path ${PROTO_OUT}/events.pb.swift --output-dir ${MODULE_DIR}/Sources/Protocol/Events --other-name EventsOther.swift
./build/anytype-swift-filesplit-v1 --path ${PROTO_OUT}/models.pb.swift --output-dir ${MODULE_DIR}/Sources/Protocol/Models --other-name ModelsOther.swift --max-depth 4
cp -r ${PROTO_OUT}/localstore.pb.swift Modules/ProtobufMessages/Sources/Protocol

