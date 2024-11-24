// swift-tools-version: 5.7.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Owl",
    products: [
        .library(
            name: "Owl",
            targets: ["Owl"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Owl",
            dependencies: []),
        .testTarget(
            name: "OwlTests",
            dependencies: ["Owl"]),
    ]
)
