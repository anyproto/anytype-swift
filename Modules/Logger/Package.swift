// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Logger",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "Logger",
            type: .dynamic,
            targets: ["Logger"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/kean/Pulse", revision: "1.1.0"),
        .package(url: "https://github.com/apple/swift-log.git", revision: "1.4.2")
    ],
    targets: [
        .target(
            name: "Logger",
            dependencies: [
                // Remove for release build. SPM proposal
                // https://github.com/apple/swift-evolution/blob/master/proposals/0273-swiftpm-conditional-target-dependencies.md
                .product(name: "Pulse", package: "Pulse"),
                .product(name: "PulseCore", package: "Pulse"),
                .product(name: "PulseUI", package: "Pulse"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources"
        )
    ]
)
