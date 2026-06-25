// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "Aether",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "Aether",
            targets: ["Aether"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "Aether"
        ),
    ]
)
