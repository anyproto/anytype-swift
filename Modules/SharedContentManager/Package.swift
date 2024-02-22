// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "SharedContentManager",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "SharedContentManager",
            type: .dynamic,
            targets: ["SharedContentManager"]),
    ],
    dependencies: [
        .package(path: "../AnytypeCore")
    ],
    targets: [
        .target(
            name: "SharedContentManager",
            dependencies: ["AnytypeCore"],
            path: "Sources"
        )
    ]
)
