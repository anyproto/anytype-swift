// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "AnytypeCore",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "AnytypeCore",
            type: .dynamic,
            targets: ["AnytypeCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.15.0"),
        .package(path: "../ProtobufMessages")
    ],
    targets: [
        .target(
            name: "AnytypeCore",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "ProtobufMessages"
            ],
            path: "AnytypeCore"
        )
    ]
)
