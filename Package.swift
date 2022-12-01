// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
	name: "DSFImageTools",
	platforms: [.macOS(.v10_11), .iOS(.v13), .tvOS(.v13)],
	products: [
		.library(
			name: "DSFImageTools",
			targets: ["DSFImageTools"]),
	],
	dependencies: [
	],
	targets: [
		.target(
			name: "DSFImageTools",
			dependencies: []),
		.testTarget(
			name: "DSFImageToolsTests",
			dependencies: ["DSFImageTools"],
			resources: [
				.process("Resources")
			]),
	]
)
