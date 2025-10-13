// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DesignKit",
    platforms: [
        .iOS(.v17),
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
        .package(url: "https://github.com/huri000/SwiftEntryKit", exact: "2.0.0"),
        .package(url: "https://github.com/hyperoslo/Cache", exact: "7.4.0")
    ],
    targets: [
        .target(
            name: "DesignKit",
            dependencies: [
                "AnytypeCore",
                "Assets",
                "AsyncTools",
                "LayoutKit",
                "SwiftEntryKit",
                "Cache"
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
