// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZDFlexLayoutKit",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZDFlexLayoutKit",
            type: .static,
            targets: [
                "ZDFlexLayoutKitObjC",
                "ZDFlexLayoutKitSwift",
            ]
        ),
    ],
    dependencies: [
        .package(name: "ZDYoga", url: "https://github.com/faimin/yoga", revision: "4e6c2d79c"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ZDFlexLayoutKitObjC",
            dependencies: ["ZDYoga"],
            path: "Sources",
            exclude: ["SwiftMaker"],
            sources: [
                "Core",
                "Header",
                "Helper",
                "OCMaker",
            ],
            publicHeadersPath: "."
        ),
        .target(
            name: "ZDFlexLayoutKitSwift",
            dependencies: [
                "ZDYoga",
                "ZDFlexLayoutKitObjC",
            ],
            path: "Sources",
            sources: [
                "SwiftMaker",
            ]
        ),
        .testTarget(
            name: "ZDFlexLayoutKitTests",
            dependencies: ["ZDFlexLayoutKitObjC", "ZDFlexLayoutKitSwift"]
        ),
    ]
)
