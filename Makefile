setup-middle:
	ruby Scripts/middleware.rb
	
update-middle:
	ruby Scripts/middleware.rb --latest

# Build from local repo

install-middle-local:
	ruby Scripts/middleware.rb --artifact-path ../anytype-heart/dist/ios

build-middle-local:
	make -C ../anytype-heart build-ios
	make -C ../anytype-heart protos-swift-local

setup-middle-local: build-middle-local install-middle-local