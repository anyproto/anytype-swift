// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "LayoutKit",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "LayoutKit",
            targets: ["LayoutKit"]),
    ],
    dependencies: [
        .package(path: "../AnytypeCore")
    ],
    targets: [
        .target(
            name: "LayoutKit",
            dependencies: [
                "AnytypeCore"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "LayoutKitTests",
            dependencies: ["LayoutKit"]
        ),
    ]
)
