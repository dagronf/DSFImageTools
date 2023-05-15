// swift-tools-version: 5.4
// The swift-tools-version declares the minimum version of Swift required to build this package.

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
		.package(
			url: "https://github.com/dagronf/SwiftImageReadWrite", .upToNextMinor(from: "1.1.3")
		),
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
