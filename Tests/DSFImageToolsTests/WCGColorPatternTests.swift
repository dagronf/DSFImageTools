@testable import DSFImageTools
import XCTest

private let markdown = MarkdownGenerator()

final class WCGColorPatternTests: XCTestCase {

	override class func setUp() {
		super.setUp()

		let name: String = {
#if os(macOS)
			getMacModel()!
#elseif os(watchOS)
			"watchOS"
#elseif os(tvOS)
			"tvOS"
#else
			UIDevice.current.localizedModel
#endif
		}()

		markdown.h1("Generated on '\(name)'")
	}

	override class func tearDown() {
		super.tearDown()

		let destination = try! tempContainer.testFilenameWithName("wcgcolorpattern.markdown")
		try! markdown.write(to: destination)
	}

	func testCGColorPatternGenerationCleanup() throws {
		// Weak, so will be 'nil'-ed when the mask pattern has deinited
		weak var holder: WCGColorPattern?

		try autoreleasepool {
			let pattern = try XCTUnwrap(WCGColorPattern(
				bounds: CGRect(x: 0, y: 0, width: 20, height: 20),
				xStep: 80,
				yStep: 80
			) { context in
				context.setStrokeColor(WCGColor.gray)
				context.setLineWidth(0.5)
				context.stroke(CGRect(x: 0, y: 0, width: 20, height: 20))

				context.addArc(
					center: CGPoint(x: 20, y: 20),
					radius: 10.0,
					startAngle: 0,
					endAngle: 2.0 * .pi,
					clockwise: false)
				context.setFillColor(CGColor.fromHexString("#0A174E")!)
				context.fillPath()
			})
			holder = pattern

			let im = try WCGImage(dimension: 200, backgroundColor: pattern.cgColor)

			XCTAssertNotNil(im)
			XCTAssertNotNil(holder)
		}

		// Because holder is 'weak', this should be nil if the WCGColorPattern has deinit-ed correctly
		XCTAssertNil(holder)
	}

	func testCGColorMaskPatternGenerationCleanup() throws {
		// Weak, so will be 'nil'-ed when the mask pattern has deinited
		weak var holder: WCGMaskPattern?

		try autoreleasepool {
			let maskPattern = try XCTUnwrap(
				WCGMaskPattern(
					bounds: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)),
					xStep: 50,
					yStep: 50
				) { ctx in
					ctx.addArc(
						center: CGPoint(x: 20, y: 20),
						radius: 10.0,
						startAngle: 0,
						endAngle: 1.3 * .pi,
						clockwise: false
					)
					ctx.fillPath()
				}
			)

			holder = maskPattern

			let maskColor = WCGColor.hex("#0ff")!
			let patternColor = maskPattern.cgColor(maskColor: maskColor)
			let image = try WCGImage(dimension: 420, backgroundColor: patternColor)

			XCTAssertNotNil(image)
			XCTAssertNotNil(holder)
		}

		// Because holder is 'weak', this should be nil if the WCGMaskPattern has deinit-ed correctly
		XCTAssertNil(holder)
	}

	func testCGColorPatternGeneration() throws {
		markdown.h2("CGColor pattern generation tests")

		markdown.raw("| color | mask1 | mask2 |\n")
		markdown.raw("|-------|-------|-------|\n")
		markdown.raw("|")

		do {
			let pattern = try XCTUnwrap(WCGColorPattern(
				bounds: CGRect(x: 0, y: 0, width: 20, height: 20),
				xStep: 80,
				yStep: 80
			) { context in
				context.setStrokeColor(WCGColor.gray)
				context.setLineWidth(0.5)
				context.stroke(CGRect(x: 0, y: 0, width: 20, height: 20))

				context.addArc(
					center: CGPoint(x: 20, y: 20),
					radius: 10.0,
					startAngle: 0,
					endAngle: 2.0 * .pi,
					clockwise: false)
				context.setFillColor(CGColor.fromHexString("#0A174E")!)
				context.fillPath()

				context.addArc(
					center: CGPoint(x: 5, y: 20),
					radius: 5.0,
					startAngle: 0,
					endAngle: 2.0 * .pi,
					clockwise: false)
				context.setFillColor(CGColor.fromHexString("#F5D042")!)
				context.fillPath()

				context.addArc(
					center: CGPoint(x: 15, y: 20),
					radius: 5.0,
					startAngle: 0,
					endAngle: 2.0 * .pi,
					clockwise: false)
				context.setFillColor(CGColor.fromHexString("#ACC7B4")!)
				context.fillPath()

			})
			let im = try WCGImage(dimension: 200, backgroundColor: pattern.cgColor)
			try markdown.image(im, linked: true)
		}
		markdown.raw("|")
		do {
			let maskPattern = try XCTUnwrap(WCGMaskPattern(
				bounds: CGRect(origin: .zero, size: CGSize(width: 20, height: 20)),
				xStep: 50,
				yStep: 50
			) { ctx in
				ctx.addArc(
					center: CGPoint(x: 20, y: 20),
					radius: 10.0,
					startAngle: 0,
					endAngle: 1.3 * .pi,
					clockwise: false
				)
				ctx.fillPath()
			}
			)

			let maskColor = WCGColor.hex("#0ff")!
			let patternColor = maskPattern.cgColor(maskColor: maskColor)

			let im = try WCGImage(dimension: 200, backgroundColor: patternColor)
			try markdown.image(im, linked: true)
			markdown.raw("|")

			let maskColor2 = WCGColor.hex("#f48")!
			let patternColor2 = maskPattern.cgColor(maskColor: maskColor2)
			let im2 = try WCGImage(dimension: 200, backgroundColor: patternColor2)
			try markdown.image(im2, linked: true)
		}
		markdown.raw("|")
		markdown.br()
	}


}
