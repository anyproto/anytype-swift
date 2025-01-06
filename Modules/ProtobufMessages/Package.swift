// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "ProtobufMessages",
    platforms: [
        .iOS(.v16),
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
            swiftSettings: [
                // Waiting swift-protobuf
                .swiftLanguageMode(.v5)
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedLibrary("resolv")
            ]
        ),
        .binaryTarget(name: "Lib", path: "../../Dependencies/Middleware/Lib.xcframework")
    ]
)
