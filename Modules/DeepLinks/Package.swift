// swift-tools-version:6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DeepLinks",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "DeepLinks",
            targets: ["DeepLinks"]),
    ],
    targets: [
        .target(
            name: "DeepLinks",
            dependencies: [],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "DeepLinksTests",
            dependencies: ["DeepLinks"]
        )
    ]
)
