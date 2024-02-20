// swift-tools-version: 5.9
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
            dependencies: []),
        .testTarget(
            name: "DeepLinksTests",
            dependencies: ["DeepLinks"]),
    ]
)
