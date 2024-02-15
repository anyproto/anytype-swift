// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "Services",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "Services",
            type: .dynamic,
            targets: ["Services"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.21.0"),
        .package(path: "../ProtobufMessages"),
        .package(path: "../AnytypeCore")
    ],
    targets: [
        .target(
            name: "Services",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "ProtobufMessages",
                "AnytypeCore"
            ],
            path: "Sources"
        )
    ]
)
