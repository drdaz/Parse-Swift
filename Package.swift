// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "ParseSwift",
    products: [
        .library(
            name: "ParseSwift",
            targets: ["ParseSwift"])
    ],
    targets: [
        .target(
            name: "ParseSwift",
            dependencies: []),
        .testTarget(
            name: "ParseSwiftTests",
            dependencies: ["ParseSwift"])
    ]
)
