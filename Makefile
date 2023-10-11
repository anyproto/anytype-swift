setup-middle:
	./Scripts/middle-install.sh

change-github-token:
	./Scripts/change-token.sh
# Build from local repo

install-middle-local:
	rm -f Dependencies/Middleware/*
	mkdir -p Dependencies/Middleware
	cp -r ../anytype-heart/dist/ios/ Dependencies/Middleware

build-middle-local:
	make -C ../anytype-heart build-ios
	make -C ../anytype-heart protos-swift-local

setup-middle-local: build-middle-local install-middle-local