// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "TreePicker",
		platforms: [
			.macOS(.v11)
		],
    products: [
        .library(
            name: "TreePicker",
            targets: ["TreePicker"]),
    ],
    targets: [
        .target(
            name: "TreePicker")
    ]
)
