// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "localization-sync",
    defaultLocalization: "en",
    platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8), .macCatalyst(.v15)],
    products: [
        .executable(
            name: "localization-sync",
            targets: ["localization-sync"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.0.0"),
        .package(url: "https://github.com/CoreOffice/XMLCoder", .upToNextMajor(from: "0.16.0"))
    ],
    targets: [
        .executableTarget(
            name: "localization-sync",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                "XMLCoder"
            ]),
    ]
)
