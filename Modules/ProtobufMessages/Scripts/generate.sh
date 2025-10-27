#!/usr/bin/env bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

${SCRIPT_DIR}/generate_models.sh
# ./Tools/SwiftGen/swiftgen config run --config ${SCRIPT_DIR}/Configs/swiftgen.yml
./build/sourcery --config ${SCRIPT_DIR}/Loc/sourcery.yml
