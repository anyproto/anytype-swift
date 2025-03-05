.DEFAULT_GOAL := release
RELEASE_BIN_FOLDER := $(shell xcrun swift build -c release --arch arm64 --arch x86_64 --show-bin-path)

release: build-release
	mkdir -p ./build
	@cp $(RELEASE_BIN_FOLDER)/anytype-swift-filesplit ./build/anytype-swift-filesplit

build:
	xcrun swift build -target anytype-filesplit-binary

build-release:
	xcrun swift build -c release --arch arm64 --arch x86_64

clean:
	xcrun swift package clean
