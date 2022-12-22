// swift-tools-version: 5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrialLicense",
    platforms: [
        .macOS(.v10_13),
    ],
    products: [
        .library(
            name: "TrialLicense",
            targets: ["TrialLicense"]),
        .library(
            name: "Trial",
            targets: ["Trial"]),
    ],
    dependencies: [
        .package(name: "CocoaFob", url: "https://github.com/glebd/cocoafob", .upToNextMajor(from: Version(2, 2, 1))),
    ],
    targets: [
        .target(
            name: "Trial",
            dependencies: [],
            path: "Sources/Trial",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "TrialTests",
            dependencies: ["Trial"],
            path: "Tests/TrialTests",
            exclude: ["Info.plist"]),

        .target(
            name: "TrialLicense",
            dependencies: ["Trial", "CocoaFob"],
            path: "Sources/TrialLicense",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "TrialLicenseTests",
            dependencies: ["TrialLicense"],
            path: "Tests/TrialLicenseTests",
            exclude: ["Info.plist"]),
    ]
)
