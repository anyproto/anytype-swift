#!/usr/bin/env bash
# DISABLE_KEYCHAIN_MIDDLEWARE_TOKEN - disable store token in keychain
# MIDDLEWARE_TOKEN - github token

BASEDIR=$(dirname $0)
PROJECT_DIR=${BASEDIR}/..

. ${BASEDIR}/common.sh --source-only

source Libraryfile

if [ "$CI" = true ] ; then
    if [[  -z "$MIDDLEWARE_TOKEN" ]]; then
        printf "MIDDLEWARE_TOKEN is not set\n"
        exit 1
    fi
    token=${MIDDLEWARE_TOKEN}
else
    has_token=$(has-keychain-environment-variable MIDDLEWARE_TOKEN)
    if [ ${has_token} == 0 ] ; then
        set-keychain-environment-variable MIDDLEWARE_TOKEN
    fi
    token=$(keychain-environment-variable MIDDLEWARE_TOKEN)
fi

curl https://maven.pkg.github.com/anyproto/anytype-heart/io.anyproto/anytype-heart-ios/${MIDDLE_VERSION}/anytype-heart-ios-${MIDDLE_VERSION}.gz -f --header "Authorization: token ${token}" -L --output ${PROJECT_DIR}/lib.gz
rm -rf ${PROJECT_DIR}/Dependencies/Middleware/*
mkdir -p ${PROJECT_DIR}/Dependencies/Middleware
tar xzf lib.gz -C ${PROJECT_DIR}/Dependencies/Middleware
rm lib.gz

rm -rf ${PROJECT_DIR}/Modules/ProtobufMessages/Sources/Protocol/*
cp -r ${PROJECT_DIR}/Dependencies/Middleware/protobuf/*.swift ${PROJECT_DIR}/Modules/ProtobufMessages/Sources/Protocol