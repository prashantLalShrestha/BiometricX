// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "BiometricX",
    platforms: [ .iOS(.v11)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "BiometricX",
            targets: ["BiometricX"]),
    ],
    dependencies: [
         .package(url: "https://github.com/kishikawakatsumi/KeychainAccess.git", from: "4.2.0"),
         .package(url: "https://github.com/rushisangani/BiometricAuthentication.git", from: "3.1.2"),
    ],
    targets: [
        .target(
            name: "BiometricX",
            dependencies: ["KeychainAccess", "BiometricAuthentication"],
            path: "Sources"
        ),
        .testTarget(
            name: "BiometricXTests",
            dependencies: ["BiometricX"],
            path: "BiometricXTests"),
    ]
)
