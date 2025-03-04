#!/usr/bin/env bash
# DISABLE_KEYCHAIN_MIDDLEWARE_TOKEN - disable store token in keychain
# MIDDLEWARE_TOKEN - github token

BASEDIR=$(dirname $0)
PROJECT_DIR=${BASEDIR}/..
CACHE_DIR=${PROJECT_DIR}/.libcache
CACHE_LIMIT=10

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

mkdir -p ${CACHE_DIR}

LIB_PATH=${CACHE_DIR}/lib-${MIDDLE_VERSION}.gz

if [[ ! -f "$LIB_PATH" ]]; then
    LIB_PATH_TMP=${CACHE_DIR}/lib-tmp.gz

    if ! curl https://maven.pkg.github.com/anyproto/anytype-heart/io.anyproto/anytype-heart-ios/${MIDDLE_VERSION}/anytype-heart-ios-${MIDDLE_VERSION}.gz -f --header "Authorization: token ${token}" -L --output ${LIB_PATH_TMP}; then
        RED='\033[0;31m'
        TERMINATOR='\n\e[0m'
        printf "${RED}Error downloading middleware, check out token provided${TERMINATOR}"
        printf "use \"make change-github-token\" command to update token"
        exit 1
    fi

    mv "$LIB_PATH_TMP" "$LIB_PATH"
fi

rm -rf ${PROJECT_DIR}/Dependencies/Middleware/*
mkdir -p ${PROJECT_DIR}/Dependencies/Middleware
tar xzf ${LIB_PATH} -C ${PROJECT_DIR}/Dependencies/Middleware

rm -rf ${PROJECT_DIR}/Modules/ProtobufMessages/Sources/Protocol/*
cp -r ${PROJECT_DIR}/Dependencies/Middleware/protobuf/*.swift ${PROJECT_DIR}/Modules/ProtobufMessages/Sources/Protocol

# Clean cache dir
if [[ -d "$CACHE_DIR" ]]; then

    FILE_COUNT=$(find "$CACHE_DIR" -type f -name "lib-*.gz" | wc -l | tr -d ' ')
    if [[ $FILE_COUNT -gt $CACHE_LIMIT ]]; then
        echo "Remove cache:"
        find "$CACHE_DIR" -type f -name "lib-*.gz" -exec stat -f "%m %N" {} + | sort -n | head -n $(($FILE_COUNT - $CACHE_LIMIT)) | cut -d ' ' -f2- | tee /dev/stderr | while IFS= read -r file; do
            rm -f -- "$file"
        done
    fi
fi

GREEN='\033[0;32m'
printf "${GREEN}Success"
echo -e "\a" # play sound