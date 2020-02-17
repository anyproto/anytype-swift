#!/usr/bin/env bash

LIBSFILE_PATH="libraryfile.lock"
MIDDLEWARE_VERSION="middleware.version"

REPO="anytypeio/go-anytype-middleware"
FILE="lib.tar.gz"
GITHUB="api.github.com"
IOS_MIDDLE_PREFIX_NAME="ios_framework_"
MIDDLEWARE_NAME="Lib.framework"
PROTO_DIR_NAME="protobuf"


#echo -n "GitHub auth token: "
#read -s token
#printf "\n"

token='4b7e2777e67f163d955660be00b09f239cc811fb'

if [ "$token" = "" ]; then
  echo "ERROR: token is empty"
  exit 1
fi;

version=`curl -H "Authorization: token $token" -H "Accept: application/vnd.github.v3+json" -sL https://$GITHUB/repos/$REPO/releases | jq ".[0]"`
tag=`echo $version | jq ".tag_name"`
asset_id=`echo $version | jq ".assets | map(select(.name | match(\"$IOS_MIDDLE_PREFIX_NAME\";\"i\")))[0].id"`

if [ "$asset_id" = "" ]; then
  echo "ERROR: version not found"
  exit 1
fi;

printf "Version: $tag\n"
printf "Found asset: $asset_id\n"
echo -n "Downloading file... "
curl -sL -H 'Accept: application/octet-stream' https://$token:@$GITHUB/repos/$REPO/releases/assets/$asset_id > $FILE
printf "Done\n"

echo -n "Uncompressing... "

mkdir /tmp/lib

tar -zxf $FILE -C /tmp/lib/
printf "Done\n"

printf "Preparing files\n"

rm -rf Dependencies/

DEPENDENCIES_DIR="Dependencies/Middleware/"

mkdir -p $DEPENDENCIES_DIR
mv /tmp/lib/$MIDDLEWARE_NAME $DEPENDENCIES_DIR
mv /tmp/lib/$PROTO_DIR_NAME $DEPENDENCIES_DIR

rm -rf /tmp/lib
rm -rf $FILE

printf "Done with downloading the library!\n"

rm -rf $LIBSFILE_PATH

printf "Copy proto files\n"

mv $DEPENDENCIES_DIR/$PROTO_DIR_NAME/commands.pb.swift AnyType/Sources/Models/ProtocolBufferObjects/
mv $DEPENDENCIES_DIR/$PROTO_DIR_NAME/events.pb.swift AnyType/Sources/Models/ProtocolBufferObjects/
mv $DEPENDENCIES_DIR/$PROTO_DIR_NAME/models.pb.swift AnyType/Sources/Models/ProtocolBufferObjects/

printf "Generate services from proto file\n"

ruby Scripts/anytype_swift_codegen.rb

echo "Creating configuration file..."

touch $LIBSFILE_PATH

echo "$MIDDLEWARE_VERSION=$tag" >> $LIBSFILE_PATH

echo Configuration file has been successfully created. It contains following properties:

cat $LIBSFILE_PATH

echo Update finished.
echo Now you can rebuild your project. Good luck!
