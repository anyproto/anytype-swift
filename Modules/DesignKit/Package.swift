// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignKit",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "DesignKit",
            targets: ["DesignKit"]),
    ],
    dependencies: [
        .package(path: "../AnytypeCore")
    ],
    targets: [
        .target(
            name: "DesignKit",
            dependencies: [
                "AnytypeCore"
            ],
            resources: [
                .process("Resources")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "DesignKitTests",
            dependencies: ["DesignKit"]
        ),
    ]
)
