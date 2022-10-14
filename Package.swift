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
            name: "Shared",
            path: "Sources/Shared"),
        .target(
            name: "SharedTests",
            path: "Tests/Shared"),

        .target(
            name: "Trial",
            dependencies: ["Shared"],
            path: "Sources/Trial",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "TrialTests",
            dependencies: ["Trial", "SharedTests"],
            path: "Tests/TrialTests",
            exclude: ["Info.plist"]),

        .target(
            name: "TrialLicense",
            dependencies: ["Trial", "Shared", "CocoaFob"],
            path: "Sources/TrialLicense",
            exclude: ["Info.plist"]),
        .testTarget(
            name: "TrialLicenseTests",
            dependencies: ["TrialLicense", "SharedTests"],
            path: "Tests/TrialLicenseTests",
            exclude: ["Info.plist"]),
    ]
)
