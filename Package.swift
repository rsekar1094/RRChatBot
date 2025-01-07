// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RRAppChatAgent",
    platforms: [
        .iOS(.v17)
        ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "RRAppChatAgent",
            targets: ["RRAppChatAgent"]),
    ],
    dependencies: [
        .package(url: "https://github.com/rsekar1094/RRAppFrameworks.git", branch: "main"),
        .package(url: "https://github.com/rsekar1094/RRMediaView.git", branch: "main")
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "RRAppChatAgent",
            dependencies: [
                .product(name: "RRAppNetwork", package: "RRAppFrameworks"),
                .product(name: "RRAppTheme", package: "RRAppFrameworks"),
                .product(name: "RRAppUtils", package: "RRAppFrameworks"),
                .product(name: "RRAppExtension", package: "RRAppFrameworks"),
                .product(name: "RRMediaView", package: "RRMediaView")
            ],
            resources: [
                .process("Resources")
            ]
        ),

    ]
)
