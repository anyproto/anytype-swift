#!/usr/bin/env bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

LOC_ROOT="${SCRIPT_DIR}/../Sources/Loc"

./build/swiftgen config run --config ${SCRIPT_DIR}/Configs/swiftgen.yml
./build/xcstrings-tool generate ${LOC_ROOT}/Resources/Localizable.xcstrings -o ${LOC_ROOT}/Generated/NewStrings.swift -a public -d en -v
