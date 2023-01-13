// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "ProtobufMessages",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "ProtobufMessages",
            type: .dynamic,
            targets: ["ProtobufMessages"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.15.0")
    ],
    targets: [
        .target(
            name: "ProtobufMessages",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "Lib"
            ],
            path: "Sources"
        ),
        .binaryTarget(name: "Lib", path: "../../Dependencies/Middleware/Lib.xcframework")
    ]
)
