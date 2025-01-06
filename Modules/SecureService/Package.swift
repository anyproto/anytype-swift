// swift-tools-version:6.0
import PackageDescription

let package = Package(
    name: "SecureService",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "SecureService",
            type: .dynamic,
            targets: ["SecureService"]),
    ],
    targets: [
        .target(
            name: "SecureService",
            path: "SecureService",
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        )
    ]
)
