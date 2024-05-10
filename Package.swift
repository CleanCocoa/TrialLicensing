// swift-tools-version: 5.5

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
        .package(name: "CocoaFob", url: "https://github.com/glebd/cocoafob", from: Version("2.4.0")),
    ],
    targets: [
        .target(
            name: "Trial",
            dependencies: [],
            path: "Sources/Trial",
            exclude: ["Info.plist"],
            resources: [.process("Resources/PrivacyInfo.xcprivacy")]),
        .testTarget(
            name: "TrialTests",
            dependencies: ["Trial"],
            path: "Tests/TrialTests",
            exclude: ["Info.plist"]),
        .target(
            name: "TrialLicense",
            dependencies: ["Trial", "CocoaFob"],
            path: "Sources/TrialLicense",
            exclude: ["Info.plist"],
            resources: [.process("Resources/PrivacyInfo.xcprivacy")]),
        .testTarget(
            name: "TrialLicenseTests",
            dependencies: ["TrialLicense"],
            path: "Tests/TrialLicenseTests",
            exclude: ["Info.plist"]),
    ]
)
