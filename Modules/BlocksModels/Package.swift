// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "BlocksModels",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "BlocksModels",
            type: .dynamic,
            targets: ["BlocksModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.15.0"),
        .package(path: "../ProtobufMessages"),
        .package(path: "../AnytypeCore")
    ],
    targets: [
        .target(
            name: "BlocksModels",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "ProtobufMessages",
                "AnytypeCore"
            ],
            path: "Sources"
        )
    ]
)
