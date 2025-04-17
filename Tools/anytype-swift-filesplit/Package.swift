// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "anytype-swift-filesplit",
    platforms: [
        .macOS(.v13)
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", revision: "600.0.1"),
        .package(url: "https://github.com/apple/swift-argument-parser", revision: "1.2.1")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .executableTarget(
            name: "anytype-swift-filesplit",
            dependencies: [
                "AnytypeSwiftFilesplit",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        .target(
            name: "AnytypeSwiftFilesplit",
            dependencies: [
                .product(name: "SwiftParser", package: "swift-syntax"),
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
            ]
        ),
        .testTarget(
             name: "AnytypeSwiftFilesplitTests",
             dependencies: [
                 "AnytypeSwiftFilesplit"
         ])
    ]
)
