// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ServerManager",
    platforms: [
        .iOS(.v13),
        .tvOS(.v12),
        .macOS(.v11)
    ],
    products: [
        .library(
            name: "ServerManager",
            targets: ["ServerManager"]
        ),
    ],
    targets: [
        .target(
            name: "ServerManager"
        ),
        .testTarget(
            name: "ServerManagerTests",
            dependencies: ["ServerManager"]
        ),
    ]
)
