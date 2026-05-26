// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "LoyaltyPointsServiceIOS",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .library(
            name: "LoyaltyPointsServiceIOS",
            targets: ["LoyaltyPointsServiceIOS"]
        )
    ],
    targets: [
        .target(
            name: "LoyaltyPointsServiceIOS"
        ),
        .testTarget(
            name: "LoyaltyPointsServiceIOSTests",
            dependencies: ["LoyaltyPointsServiceIOS"]
        )
    ]
)
