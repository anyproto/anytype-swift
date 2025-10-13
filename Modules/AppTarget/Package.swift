// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AppTarget",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "AppTarget",
            targets: ["AppTarget"]),
    ],
    targets: [
        .target(
            name: "AppTarget",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
