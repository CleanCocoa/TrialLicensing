// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "TrialLicense",
    platforms: [.macOS(.v10_10)],
    products: [
        .library(
            name: "TrialLicense",
            targets: ["TrialLicense"]),
        .library(
            name: "Trial",
            targets: ["Trial"]),
    ],
    dependencies: [
        .package(name: "CocoaFob", url: "https://github.com/glebd/cocoafob", .branchItem("ctietze/swiftpm")),
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
