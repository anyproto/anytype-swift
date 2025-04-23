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
        .package(path: "../AnytypeCore"),
        .package(path: "../Assets"),
        .package(path: "../AsyncTools"),
        .package(path: "../LayoutKit"),
        .package(url: "https://github.com/bududomasidet/SwiftEntryKit", exact: "1.0.0")
    ],
    targets: [
        .target(
            name: "DesignKit",
            dependencies: [
                "AnytypeCore",
                "Assets",
                "AsyncTools",
                "LayoutKit"
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
