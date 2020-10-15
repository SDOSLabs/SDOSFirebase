// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "SDOSFirebase",
    platforms: [
        .iOS(.v9)
    ],
    products: [
        .library(
            name: "SDOSFirebase",
            targets: ["SDOSFirebase"])
    ],
    dependencies: [
        .package(name: "Firebase", url: "https://github.com/firebase/firebase-ios-sdk.git", .branch("6.34-spm-beta"))
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
