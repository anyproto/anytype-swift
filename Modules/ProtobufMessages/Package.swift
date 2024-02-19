// swift-tools-version:5.9
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
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.21.0")
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
                .linkedLibrary("c++"),
                .linkedLibrary("resolv")
            ]
        ),
        .binaryTarget(name: "Lib", path: "../../Dependencies/Middleware/Lib.xcframework")
    ]
)
