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
            type: .dynamic,
            targets: ["NotificationsCore"]),
    ],
    dependencies: [
        .package(path: "../AnytypeCore"),
        .package(path: "../SecureService"),
    ],
    targets: [
        .target(
            name: "NotificationsCore",
            dependencies: [
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
