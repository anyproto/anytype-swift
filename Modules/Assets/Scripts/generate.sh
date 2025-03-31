#!/usr/bin/env bash

# Script root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cd $SCRIPT_DIR

cd ../Templates/

TEMPLATE_DIR=$(pwd)

# Project Root
cd ../../../

./Tools/SwiftGen/swiftgen config run --config ${TEMPLATE_DIR}/swiftgen.yml
