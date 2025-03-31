// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "Loc",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "Loc",
            targets: ["Loc"]),
    ],
    targets: [
        .target(
            name: "Loc",
            resources: [.process("Resources")],
            swiftSettings: [
                .swiftLanguageMode(.v6)
            ]
        ),
        .testTarget(
            name: "LocTests",
            dependencies: ["Loc"]
        ),
    ]
)
