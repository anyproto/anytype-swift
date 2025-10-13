// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AsyncTools",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "AsyncTools",
            targets: ["AsyncTools"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-async-algorithms", revision: "1.0.3")
    ],
    targets: [
        .target(
            name: "AsyncTools",
            dependencies: [
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "AsyncToolsTests",
            dependencies: ["AsyncTools"]
        ),
    ]
)
