// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "NetworkXI",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "NetworkXI",
            targets: ["NetworkXI"]
        ),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NetworkXI",
            dependencies: []
        ),
        .testTarget(
            name: "NetworkXITests",
            dependencies: ["NetworkXI"],
            resources: [
                .process("httpbin.org.cer"),
                .process("Assets.xcassets")
            ]
        )
    ]
)
