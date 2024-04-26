setup-middle:
	./Scripts/middle-install.sh
	make generate

change-github-token:
	./Scripts/change-token.sh
# Build from local repo

generate:
	sourcery --config ./Modules/ProtobufMessages/sourcery.yml
	./Tools/anytype-swift-codegen --yaml-path ./Modules/ProtobufMessages/anytypeGen.yml --project-dir ./Modules/ProtobufMessages --output-dir ./Modules/ProtobufMessages/Sources/Generated
	./Tools/SwiftGen/swiftgen --config ./Modules/Services/swiftgen.yml
	sourcery --config ./Modules/AnytypeCore/sourcery.yml
	sourcery --config ./Anytype/GeneratorConfig/sourcery.yml

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