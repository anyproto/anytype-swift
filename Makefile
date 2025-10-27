FILE_SPLITTER = ./build/anytype-swift-filesplit-v1
BOLD := \033[1m
GREEN := \033[32m
RESET := \033[0m

setup-middle:
	./Scripts/middle-download.sh
	make generate-middle

setup-middle-ci:
	./Scripts/middle-download.sh

change-github-token:
	# Token generation info:
	# https://github.com/anyproto/anytype-swift?tab=readme-ov-file#use-pre-built-anytype-heart
	./Scripts/change-token.sh

generate-middle:
	@echo "$(BOLD)If you encounter issues with generation, run $(GREEN)setup-env$(RESET)"
	./Modules/ProtobufMessages/Scripts/generate.sh
	./build/sourcery --config ./Modules/ProtobufMessages/sourcery.yml
	./Tools/anytype-swift-codegen --yaml-path ./Modules/ProtobufMessages/anytypeGen.yml --project-dir ./Modules/ProtobufMessages --output-dir ./Modules/ProtobufMessages/Sources/Generated
	./build/swiftgen --config ./Modules/Services/swiftgen.yml

generate:
	@echo "$(BOLD)If you encounter issues with generation, run $(GREEN)setup-env$(RESET)"
	# We also have code generation in XCode Build phases for main target and widgets
	./build/sourcery --config ./Modules/AnytypeCore/sourcery.yml
	./Modules/Assets/Scripts/generate.sh
	./Modules/Loc/Scripts/generate.sh
	./Modules/DesignKit/Scripts/generate.sh

install-middle-local:
	rm -fr Dependencies/Middleware/*
	mkdir -p Dependencies/Middleware
	cp -r ../anytype-heart/dist/ios/ Dependencies/Middleware
	make generate-middle

build-middle-local:
	make -C ../anytype-heart build-ios
	make -C ../anytype-heart protos-swift-local

setup-middle-local: build-middle-local install-middle-local

setup-env: setup-file-splitter
	./Scripts/install-sourcery.sh
	./Scripts/install-swiftprotobuf.sh
	brew install ubi
	ubi --project "mgolovko/SwiftGen" --tag "6.6.4-alpha.0" --matching "swiftgen-6.6.4-alpha.0-macos.zip" --exe swiftgen --in ./build

set-middle-version:
	echo "MIDDLE_VERSION=$(v)" > Libraryfile

setup-file-splitter:
	@if [ ! -f "$(FILE_SPLITTER)" ]; then \
		make release -C Tools/anytype-swift-filesplit; \
		mkdir -p build; \
		cp Tools/anytype-swift-filesplit/build/anytype-swift-filesplit $(FILE_SPLITTER); \
	fi
	
