// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "AnytypeCore",
    platforms: [
        .iOS(.v14),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "AnytypeCore",
            type: .dynamic,
            targets: ["AnytypeCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.15.0"),
        .package(path: "../ProtobufMessages"),
        .package(path: "../Logger"),
        // Waiting issue - https://github.com/krzysztofzablocki/Sourcery/issues/1090
        .package(url: "https://github.com/mgolovko/SourceryGenPlugin.git", revision: "1.9.2")
    ],
    targets: [
        .target(
            name: "AnytypeCore",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "ProtobufMessages",
                "Logger"
            ],
            path: "AnytypeCore",
            plugins: [
                .plugin(name: "SourceryGenPlugin", package: "SourceryGenPlugin")
            ]
        )
    ]
)
