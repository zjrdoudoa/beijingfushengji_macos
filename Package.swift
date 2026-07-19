// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "BeijingFushengjiMac",
    defaultLocalization: "zh-Hans",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "FushengjiCore",
            targets: ["FushengjiCore"]
        ),
        .executable(
            name: "FushengjiMac",
            targets: ["FushengjiMac"]
        ),
        .executable(
            name: "FushengjiCoreSelfTests",
            targets: ["FushengjiCoreSelfTests"]
        )
    ],
    targets: [
        .target(
            name: "FushengjiCore",
            resources: [
                .process("Resources")
            ]
        ),
        .executableTarget(
            name: "FushengjiMac",
            dependencies: ["FushengjiCore"]
        ),
        .executableTarget(
            name: "FushengjiCoreSelfTests",
            dependencies: ["FushengjiCore"]
        )
    ]
)
