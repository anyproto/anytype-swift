// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "AnytypeCore",
    platforms: [
        .iOS(.v17),
    ],
    products: [
        .library(
            name: "AnytypeCore",
            type: .dynamic,
            targets: ["AnytypeCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.28.2"),
        .package(path: "../Logger"),
        .package(path: "../AppTarget")
    ],
    targets: [
        .target(
            name: "AnytypeCore",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "Logger",
                "AppTarget"
            ],
            path: "AnytypeCore",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "AnytypeCoreTests",
            dependencies: [
                "AnytypeCore"
            ]),
    ]
)
