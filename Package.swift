// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ZDFlexLayoutKit",
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "ZDFlexLayoutKit",
            targets: ["ZDFlexLayoutObjC", "ZDFlexLayoutSwift"]
        ),
    ],
	dependencies: [
         // 当前Package依赖的外部依赖项，以local package相对路径为例
         //.package(name: "UserAndSetting", path: "../UserAndSetting"),
		 .package(url: "https://github.com/facebook/yoga.git", from: "3.2.1")
     ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "ZDFlexLayoutObjC",
			dependencies: [
				.product(name: "yoga", package: "yoga")
			],
			path: "Sources",
			sources: ["Core", "Header", "Helper", "OCMaker"],
			resources: [.process("Resource/PrivacyInfo.xcprivacy")],
			publicHeadersPath: ".",
			cSettings: [
				.headerSearchPath("Core/Public"),
				.headerSearchPath("Core/Private"),
				.headerSearchPath("Header"),
				.headerSearchPath("Helper"),
				.headerSearchPath("OCMaker")
			]
        ),
		.target(
            name: "ZDFlexLayoutSwift",
			dependencies: [
				.product(name: "yoga", package: "yoga"),
				"ZDFlexLayoutObjC"
			],
			path: "Sources",
			sources: ["SwiftMaker"],
        ),
        .testTarget(
            name: "ZDFlexLayoutKitTests",
            dependencies: ["ZDFlexLayoutObjC", "ZDFlexLayoutSwift"],
        ),
    ],
)
