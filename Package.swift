// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SDOSFirebase",
    platforms: [
        .iOS(.v10)
    ],
    products: [
        .library(
            name: "SDOSFirebase",
            targets: ["SDOSFirebase"])
    ],
    dependencies: [
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", .upToNextMajor(from: "7.0.0"))
    ],
    targets: [
        .target(
            name: "SDOSFirebase",
            dependencies: [
                .product(name: "FirebaseAnalytics", package: "Firebase")
            ],
            path: "src"
        ),
    ]
)
