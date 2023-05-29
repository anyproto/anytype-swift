// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "ProtobufMessages",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "ProtobufMessages",
            type: .dynamic,
            targets: ["ProtobufMessages"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.21.0"),
        .package(url: "git@github.com:anytypeio/anytype-swift-codegen.git", revision: "0.0.11"),
        .package(url: "https://github.com/anyproto/SourceryGenPlugin.git", revision: "1.9.2")
    ],
    targets: [
        .target(
            name: "ProtobufMessages",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "Lib"
            ],
            path: "Sources",
            linkerSettings: [
                .linkedLibrary("c++")
            ],
            plugins: [
                .plugin(name: "ServiceGenPlugin", package: "AnytypeSwiftCodegen"),
                .plugin(name: "SourceryGenPlugin", package: "SourceryGenPlugin")
            ]
        ),
        .binaryTarget(name: "Lib", path: "../../Dependencies/Middleware/Lib.xcframework")
    ]
)
