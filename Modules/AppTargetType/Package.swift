// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppTargetType",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "AppTargetType",
            targets: ["AppTargetType"]),
    ],
    targets: [
        .target(
            name: "AppTargetType",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
