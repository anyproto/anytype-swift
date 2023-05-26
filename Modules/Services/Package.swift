// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Services",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "Services",
            type: .dynamic,
            targets: ["Services"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.21.0"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", revision: "6.6.2"),
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
            path: "Sources",
            plugins: [
                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
            ]
        )
    ]
)
