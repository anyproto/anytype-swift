// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "BlocksModels",
    platforms: [
        .iOS(.v14),
    ],
    products: [
        .library(
            name: "BlocksModels",
            type: .dynamic,
            targets: ["BlocksModels"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.15.0"),
        .package(url: "https://github.com/SwiftGen/SwiftGenPlugin", revision: "6.6.2"),
        .package(path: "../ProtobufMessages"),
        .package(path: "../AnytypeCore")
    ],
    targets: [
        .target(
            name: "BlocksModels",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "ProtobufMessages",
                "AnytypeCore"
            ],
            path: "Sources"
            // Plugin command not running in Xcode 13
            // https://forums.swift.org/t/plugin-command-not-running-when-package-is-indirectly-included-in-xcode-project/57168/4
            // Enable for xcode 14. Delete json section in general swiftgen.yml
//            plugins: [
//                .plugin(name: "SwiftGenPlugin", package: "SwiftGenPlugin")
//            ]
        )
    ]
)
