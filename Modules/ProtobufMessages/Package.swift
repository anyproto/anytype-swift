// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "ProtobufMessages",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "ProtobufMessages",
            type: .dynamic,
            targets: ["ProtobufMessages"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.28.2")
    ],
    targets: [
        .target(
            name: "ProtobufMessages",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "Lib"
            ],
            path: "Sources",
            resources: [.process("Loc/Resources")],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedLibrary("resolv")
            ]
        ),
        .testTarget(
            name: "ProtobufMessagesTests",
            dependencies: ["ProtobufMessages"]
        ),
        .binaryTarget(name: "Lib", path: "../../Dependencies/Middleware/Lib.xcframework")
    ]
)
