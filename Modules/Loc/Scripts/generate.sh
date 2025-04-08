#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

./build/swiftgen config run --config ${SCRIPT_DIR}/Configs/swiftgen.yml
