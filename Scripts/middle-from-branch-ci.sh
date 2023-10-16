#!/usr/bin/env bash

BASEDIR=$(dirname $0)
PROJECT_DIR=${BASEDIR}/..

source Libraryfile

git clone git@github.com:anyproto/anytype-heart.git build/anytype-heart
cd build/anytype-heart
git checkout ${MIDDLE_VERSION}

rm -f staging.yml
echo "$ANY_SYNC_NETWORK_FILE" > staging.yml

ANY_SYNC_NETWORK=staging.yml make build-ios
ANY_SYNC_NETWORK=staging.yml make protos-swift-local

cd ../../
rm -fr Dependencies/Middleware/*
mkdir -p Dependencies/Middleware
cp -r build/anytype-heart/dist/ios/ Dependencies/Middleware