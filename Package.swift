// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "FitGlass",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
    ],
    products: [
        .executable(
            name: "FitGlass",
            targets: ["FitGlass"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "FitGlass"
        ),
    ]
)
