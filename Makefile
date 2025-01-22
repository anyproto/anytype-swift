setup-middle:
	./Scripts/middle-install.sh
	make generate

setup-middle-ci:
	./Scripts/middle-install.sh
	make patch-commands-pb

change-github-token:
	# Token generation info:
	# https://github.com/anyproto/anytype-swift?tab=readme-ov-file#use-pre-built-anytype-heart
	./Scripts/change-token.sh

generate:
	./Tools/anytype-swift-codegen --yaml-path ./Modules/ProtobufMessages/anytypeGen.yml --project-dir ./Modules/ProtobufMessages --output-dir ./Modules/ProtobufMessages/Sources/Generated
	./Tools/SwiftGen/swiftgen --config ./Modules/Services/swiftgen.yml
	sourcery --config ./Modules/AnytypeCore/sourcery.yml
	sourcery --config ./Anytype/GeneratorConfig/sourcery.yml
	# We also have code generation in XCode Build phases for main target and widgets
	make patch-commands-pb

patch-commands-pb:
	./Scripts/generate_response_extensions.sh ./Modules/ProtobufMessages/Sources/Protocol/commands.pb.swift


update-xcfilelists:
	./Tools/SwiftGen/swiftgen config generate-xcfilelists --config ./Tools/SwiftGen/swiftgen.yml --inputs ./Tools/SwiftGen/swiftgen-inputs-files.xcfilelist --outputs ./Tools/SwiftGen/swiftgen-outputs-files.xcfilelist
	./Tools/SwiftGen/swiftgen config generate-xcfilelists --config ./Tools/SwiftGen/swiftgen-we.yml --inputs ./Tools/SwiftGen/swiftgen-inputs-files-we.xcfilelist --outputs ./Tools/SwiftGen/swiftgen-outputs-files-we.xcfilelist

install-middle-local:
	rm -fr Dependencies/Middleware/*
	mkdir -p Dependencies/Middleware
	cp -r ../anytype-heart/dist/ios/ Dependencies/Middleware
	rm -rf Modules/ProtobufMessages/Sources/Protocol/*
	cp -r Dependencies/Middleware/protobuf/*.swift Modules/ProtobufMessages/Sources/Protocol
	make generate

build-middle-local:
	make -C ../anytype-heart build-ios
	make -C ../anytype-heart protos-swift-local

setup-middle-local: build-middle-local install-middle-local

setup-env:
	brew install sourcery

set-middle-version:
	echo "MIDDLE_VERSION=$(v)" > Libraryfile
