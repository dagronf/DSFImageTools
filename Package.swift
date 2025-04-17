// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "DSFImageTools",
	platforms: [.macOS(.v10_11), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
	products: [
		.library(
			name: "DSFImageTools",
			targets: ["DSFImageTools"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/SwiftImageReadWrite", from: "1.1.3"),
	],
	targets: [
		.target(
			name: "DSFImageTools",
			dependencies: ["SwiftImageReadWrite"]),
		.testTarget(
			name: "DSFImageToolsTests",
			dependencies: ["DSFImageTools"],
			resources: [
				.process("Resources")
			]),
	]
)
