setup-middle:
	./Scripts/middle-install.sh

change-github-token:
	./Scripts/change-token.sh
# Build from local repo

install-middle-local:
	rm -fr Dependencies/Middleware/*
	mkdir -p Dependencies/Middleware
	cp -r ../anytype-heart/dist/ios/ Dependencies/Middleware
	rm -rf Modules/ProtobufMessages/Sources/Protocol/*
	cp -r Dependencies/Middleware/protobuf/*.swift Modules/ProtobufMessages/Sources/Protocol

build-middle-local:
	make -C ../anytype-heart build-ios
	make -C ../anytype-heart protos-swift-local

setup-middle-local: build-middle-local install-middle-local