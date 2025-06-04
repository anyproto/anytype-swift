// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NotificationsCore",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "NotificationsCore",
            targets: ["NotificationsCore"]),
    ],
    dependencies: [
        .package(url: "https://github.com/anyproto/any-crypto-swift", from: "1.0.0"),
        .package(path: "../AnytypeCore"),
        .package(path: "../SecureService"),
    ],
    targets: [
        .target(
            name: "NotificationsCore",
            dependencies: [
                .product(name: "AnyCryptoSwift", package: "any-crypto-swift"),
                "AnytypeCore",
                "SecureService"
            ],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "NotificationsCoreTests",
            dependencies: ["NotificationsCore"]
        ),
    ]
)
