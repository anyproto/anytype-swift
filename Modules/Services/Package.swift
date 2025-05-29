// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "Services",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "Services",
            type: .dynamic,
            targets: ["Services"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-protobuf", revision: "1.28.2"),
        .package(url: "https://github.com/hmlongco/Factory", revision: "2.3.1"),
        .package(path: "../ProtobufMessages"),
        .package(path: "../AnytypeCore"),
        .package(path: "../SecureService"),
        .package(path: "../NotificationsCore")
    ],
    targets: [
        .target(
            name: "Services",
            dependencies: [
                .product(name: "SwiftProtobuf", package: "swift-protobuf"),
                "Factory",
                "ProtobufMessages",
                "AnytypeCore",
                "SecureService",
                "NotificationsCore"
            ],
            path: "Sources",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
