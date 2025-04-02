FILE_SPLITTER = ./build/anytype-swift-filesplit-v1

setup-middle:
	./Scripts/middle-download.sh
	make generate-middle

setup-middle-ci:
	./Scripts/middle-download.sh

change-github-token:
	# Token generation info:
	# https://github.com/anyproto/anytype-swift?tab=readme-ov-file#use-pre-built-anytype-heart
	./Scripts/change-token.sh

generate-middle: setup-tools
	rm -rf Modules/ProtobufMessages/Sources/Protocol/*
	$(FILE_SPLITTER) --path ./Dependencies/Middleware/protobuf/commands.pb.swift --output-dir ./Modules/ProtobufMessages/Sources/Protocol/Commands --other-name CommandsOther.swift
	$(FILE_SPLITTER) --path ./Dependencies/Middleware/protobuf/events.pb.swift --output-dir ./Modules/ProtobufMessages/Sources/Protocol/Events --other-name EventsOther.swift
	$(FILE_SPLITTER) --path ./Dependencies/Middleware/protobuf/models.pb.swift --output-dir ./Modules/ProtobufMessages/Sources/Protocol/Models --other-name ModelsOther.swift --max-depth 4
	cp -r Dependencies/Middleware/protobuf/localstore.pb.swift Modules/ProtobufMessages/Sources/Protocol
	sourcery --config ./Modules/ProtobufMessages/sourcery.yml
	./Tools/anytype-swift-codegen --yaml-path ./Modules/ProtobufMessages/anytypeGen.yml --project-dir ./Modules/ProtobufMessages --output-dir ./Modules/ProtobufMessages/Sources/Generated
	./Tools/SwiftGen/swiftgen --config ./Modules/Services/swiftgen.yml
	./Modules/ProtobufMessages/Scripts/generate.sh

generate:
	# We also have code generation in XCode Build phases for main target and widgets
	sourcery --config ./Modules/AnytypeCore/sourcery.yml
	./Modules/Assets/Scripts/generate.sh
	./Modules/Loc/Scripts/generate.sh

update-xcfilelists:
	./Tools/SwiftGen/swiftgen config generate-xcfilelists --config ./Tools/SwiftGen/swiftgen-we.yml --inputs ./Tools/SwiftGen/swiftgen-inputs-files-we.xcfilelist --outputs ./Tools/SwiftGen/swiftgen-outputs-files-we.xcfilelist

install-middle-local:
	rm -fr Dependencies/Middleware/*
	mkdir -p Dependencies/Middleware
	cp -r ../anytype-heart/dist/ios/ Dependencies/Middleware
	make generate-middle

build-middle-local:
	make -C ../anytype-heart build-ios
	make -C ../anytype-heart protos-swift-local

setup-middle-local: build-middle-local install-middle-local

setup-env:
	brew install sourcery

set-middle-version:
	echo "MIDDLE_VERSION=$(v)" > Libraryfile

setup-tools:
	@if [ ! -f "$(FILE_SPLITTER)" ]; then \
		make release -C Tools/anytype-swift-filesplit; \
		mkdir -p build; \
		cp Tools/anytype-swift-filesplit/build/anytype-swift-filesplit $(FILE_SPLITTER); \
	fi
