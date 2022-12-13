import XCTest
@testable import DSFImageTools


let tempContainer = TestOutputContainer(title: "WCGTestOutput")
private let markdown = MarkdownGenerator()

final class WCGImageTests: XCTestCase {
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

		let destination = try! tempContainer.testFilenameWithName("wcgimage.markdown")
		try! markdown.write(to: destination)
	}

	func testCreate() throws {
		markdown.h1("Creation tests")

		markdown.raw("| new blank | new with background color | new with drawing |\n")
		markdown.raw("|----|----|----|\n")
		markdown.raw("|")

		let orig1 = try WCGImage(dimension: 300).border(WCGColor.black)
		try markdown.image(orig1, linked: true)

		markdown.raw(" | ")
		let orig2 = try WCGImage(
			dimension: 300,
			backgroundColor: CGColor(srgbRed: 0.1, green: 0.9, blue: 0.3, alpha: 0.3)
		).border(WCGColor.black)
		try markdown.image(orig2, linked: true)

		markdown.raw(" | ")

		let orig3 = try WCGImage(
			dimension: 300,
			backgroundColor: CGColor(srgbRed: 0.1, green: 0.9, blue: 0.3, alpha: 0.3)
		) { ctx, size in
			ctx.setFillColor(WCGColor.white)
			ctx.addPath(CGPath(ellipseIn: CGRect(x: 30, y: 30, width: 100, height: 100), transform: nil))
			ctx.fillPath()
			ctx.setFillColor(WCGColor.black)
			ctx.addPath(CGPath(rect: CGRect(x: 90, y: 90, width: 100, height: 100), transform: nil))
			ctx.fillPath()
		}.border(WCGColor.black)
		try markdown.image(orig3, linked: true)

		markdown.raw(" |").br()
	}

	func testGrayTint() throws {
		markdown.h1("Color tinting tests")

		do {
			markdown.h2("Image without alpha")

			markdown.raw("| original | grayscale | tinted |\n")
			markdown.raw("|----|----|----|\n")
			markdown.raw("| ")

			let testImage = try loadImage(name: "wilsonsprom", extn: "jpeg").border(WCGColor.black)
			try markdown.image(testImage, linked: true).raw(" | ")
			let gray = try testImage.grayscale().border(WCGColor.black)
			try markdown.image(gray, linked: true).raw(" | ")
			let tint = try testImage.tinting(with: CGColor(srgbRed: 0.4, green: 0, blue: 0.4, alpha: 1)).border(WCGColor.black)
			try markdown.image(tint, linked: true).raw(" | ")
			markdown.br()
		}

		do {
			markdown.h2("Image with alpha (dropping alpha channel)")
			markdown.raw("| original | grayscale | tinted |\n")
			markdown.raw("|----|----|----|\n")
			markdown.raw("| ")

			let testImageAlpha = try loadImage(name: "apple-logo-dark", extn: "png").border(WCGColor.black)
			try markdown.image(testImageAlpha, linked: true).raw(" | ")
			let gray = try testImageAlpha.grayscale(keepingAlpha: false).border(WCGColor.black)
			try markdown.image(gray, linked: true).raw(" | ")
			let tint = try testImageAlpha.tinting(with: CGColor(srgbRed: 0.4, green: 0, blue: 0.4, alpha: 1), keepingAlpha: false).border(WCGColor.black)
			try markdown.image(tint, linked: true).raw(" | ")
			markdown.br()
		}

		do {
			markdown.h2("Image with alpha (keeping alpha channel)")
			markdown.raw("| original | grayscale | tinted |\n")
			markdown.raw("|----|----|----|\n")
			markdown.raw("| ")

			let testImageAlpha = try loadImage(name: "apple-logo-dark", extn: "png").border(WCGColor.black)
			try markdown.image(testImageAlpha, linked: true).raw(" | ")
			let gray = try testImageAlpha.grayscale(keepingAlpha: true).border(WCGColor.black)
			try markdown.image(gray, linked: true).raw(" | ")
			let tint = try testImageAlpha.tinting(with: CGColor(srgbRed: 0.4, green: 0, blue: 0.4, alpha: 1), keepingAlpha: true).border(WCGColor.black)
			try markdown.image(tint, linked: true).raw(" | ")
			markdown.br()
		}
	}

	func loadImage(name: String, extn: String) throws -> WCGImage {
		let imageURL = try XCTUnwrap(Bundle.module.url(forResource: name, withExtension: extn))
		return try WCGImage(fileURL: imageURL)
	}

	func testScaling() throws {
		markdown.h1("Scaling tests")


		let testImage = try loadImage(name: "wilsonsprom", extn: "jpeg")
		let testImageAlpha = try loadImage(name: "apple-logo-dark", extn: "png")

		do {
			markdown.h2("Image without alpha")

			markdown.raw("| axesIndependent | aspectFit | aspectFill |\n")
			markdown.raw("|----|----|----|\n")
			markdown.raw("| ")

			let s1 = try testImage.scaling(scalingType: .axesIndependent, to: CGSize(width: 300, height: 300)).border(WCGColor.black)
			try markdown.image(s1, linked: true).raw(" | ")
			let s2 = try testImage.scaling(scalingType: .aspectFit, to: CGSize(width: 300, height: 300)).border(WCGColor.black)
			try markdown.image(s2, linked: true).raw(" | ")
			let s3 = try testImage.scaling(scalingType: .aspectFill, to: CGSize(width: 300, height: 300)).border(WCGColor.black)
			try markdown.image(s3, linked: true).raw(" | ")
			markdown.br()
		}

		do {
			markdown.h2("Image with alpha")

			markdown.raw("| axesIndependent | aspectFit | aspectFill |\n")
			markdown.raw("|----|----|----|\n")
			markdown.raw("| ")

			let e1 = try testImageAlpha.scaling(scalingType: .axesIndependent, to: CGSize(width: 300, height: 300)).border(WCGColor.black)
			try markdown.image(e1, linked: true).raw(" | ")
			let e2 = try testImageAlpha.scaling(scalingType: .aspectFit, to: CGSize(width: 300, height: 300)).border(WCGColor.black)
			try markdown.image(e2, linked: true).raw(" | ")
			let e3 = try testImageAlpha.scaling(scalingType: .aspectFill, to: CGSize(width: 300, height: 300)).border(WCGColor.black)
			try markdown.image(e3, linked: true).raw(" | ")
			markdown.br()
		}
	}

	func testRotate() throws {
		markdown.h1("Rotation tests")

		let testImage = try loadImage(name: "wilsonsprom", extn: "jpeg")
		let testImageAlpha = try loadImage(name: "apple-logo-dark", extn: "png")

		do {
			markdown.h2("Image without alpha")
			markdown.raw("|    |    |    |\n")
			markdown.raw("|----|----|----|\n")
			markdown.raw("| ")

			let s1 = try testImage.rotating(by: 0.8).border(WCGColor.black)
			try markdown.image(s1, linked: true).raw(" | ")
			let s2 = try testImage.rotating(by: 1.8).border(WCGColor.black)
			try markdown.image(s2, linked: true).raw(" | ")
			let s3 = try testImage.rotating(by: 2.8).border(WCGColor.black)
			try markdown.image(s3, linked: true).raw(" | ").br()
		}

		do {
			markdown.h2("Image with alpha")
			markdown.raw("|    |    |    |\n")
			markdown.raw("|----|----|----|\n")
			markdown.raw("| ")

			let e1 = try testImageAlpha.rotating(by: 0.8).border(WCGColor.black)
			try markdown.image(e1, linked: true).raw(" | ")
			let e2 = try testImageAlpha.rotating(by: 1.8).border(WCGColor.black)
			try markdown.image(e2, linked: true).raw(" | ")
			let e3 = try testImageAlpha.rotating(by: 2.8).border(WCGColor.black)
			try markdown.image(e3, linked: true).raw(" | ")
		}
	}

	func testFlip() throws {
		markdown.h1("Flipping tests")

		let testImage = try loadImage(name: "wilsonsprom", extn: "jpeg").scaling(by: 0.3)
		let testImageAlpha = try loadImage(name: "apple-logo-dark", extn: "png").scaling(by: 0.3)

		do {
			try markdown.h2("Original image without alpha").image(try testImage.cgImage()).br()
			let s1 = try testImage.flipping(.horizontally).border(WCGColor.black)
			try markdown.h3("horizontally").br().image(s1, linked: true).br()
			let s2 = try testImage.flipping(.vertically).border(WCGColor.black)
			try markdown.h3("vertically").br().image(s2, linked: true).br()
			let s3 = try testImage.flipping(.both).border(WCGColor.black)
			try markdown.h3("both").br().image(s3, linked: true).br()
		}

		do {
			try markdown.h2("Original image with alpha").image(try testImageAlpha.cgImage()).br()
			let e1 = try testImageAlpha.flipping(.horizontally).border(WCGColor.black)
			try markdown.h3("horizontally").br().image(e1, linked: true).br()
			let e2 = try testImageAlpha.flipping(.vertically).border(WCGColor.black)
			try markdown.h3("vertically").br().image(e2, linked: true).br()
			let e3 = try testImageAlpha.flipping(.both).border(WCGColor.black)
			try markdown.h3("both").br().image(e3, linked: true).br()
		}
	}

	func testDrawingOnImage() throws {

		markdown.h1("Drawing on an image")

		let testImage = try loadImage(name: "wilsonsprom", extn: "jpeg").scaling(by: 0.5)
		let drawn = try testImage.drawing { ctx, size in
			ctx.setFillColor(CGColor(srgbRed: 1, green: 1, blue: 0.3, alpha: 1))
			ctx.addPath(
				CGPath(
					roundedRect: CGRect(x: 10, y: 10, width: 50, height: 50),
					cornerWidth: 10, cornerHeight: 10,
					transform: nil
				)
			)
			ctx.fillPath()
		}
		try markdown.image(drawn, linked: true).br()
	}

	func testCropping() throws {
		markdown.h1("Cropping")
		let testImage = try loadImage(name: "colorful-skull", extn: "jpg") //.scaling(by: 0.5)

		do {
			markdown.raw("| Original | Cropped 1 | Cropped 2 | Cropped 3 |\n")
			markdown.raw("|:----:|:----:|:----:|:----:|\n").raw("| ")
			let sz1 = try testImage.size()
			try markdown.image(testImage, width: 200, linked: true).raw("</br> \(sz1.width) x \(sz1.height)")
			markdown.raw(" | ")
			do {
				let cropped = try testImage.cropping(to: CGRect(x: 40, y: 40, width: 100, height: 100))
				let sz2 = try cropped.size()
				try markdown.image(cropped, linked: true).raw("</br> 40,40 : \(sz2.width) x \(sz2.height)")
			}
			markdown.raw(" | ")
			do {
				let cropped2 = try testImage.cropping(to: CGRect(x: 100, y: 100, width: 250, height: 400))
				let sz2 = try cropped2.size()
				try markdown.image(cropped2, height: 200, linked: true).raw("</br> 100,100 : \(sz2.width) x \(sz2.height)")
			}
			markdown.raw(" | ")
			do {
				let cropped2 = try testImage.cropping(to: CGRect(x: 200, y: 110, width: 200, height: 500))
				let sz2 = try cropped2.size()
				try markdown.image(cropped2, height: 200, linked: true).raw("</br> 200,110 : \(sz2.width) x \(sz2.height)")
			}
			markdown.br()
		}
	}

	func testAdjustments() throws {
		markdown.h1("Image color adjustments")

		let testImage = try loadImage(name: "colorful-skull", extn: "jpg") //.scaling(by: 0.5)

		#if canImport(CoreImage)
		do {
			markdown.raw("| Original | ⬆︎ Saturation | ⬆︎ Contrast | ⬆︎ Brightness |\n")
			markdown.raw("|----|----|----|----|\n")
			markdown.raw("|")
			try markdown.image(testImage)
			markdown.raw("| ")
			let sat = try testImage.adjustingColors(saturation: 1.8)
			try markdown.image(sat, linked: true)
			markdown.raw(" | ")
			let contr = try testImage.adjustingColors(contrast: 3.3)
			try markdown.image(contr, linked: true)
			markdown.raw(" | ")
			let bri = try testImage.adjustingColors(brightness: 0.612)
			try markdown.image(bri, linked: true)
			markdown.raw(" |\n").br()
		}

		do {
			markdown.raw("| Original | ⬇︎ Saturation | ⬇︎ Contrast | ⬇︎ Brightness |\n")
			markdown.raw("|----|----|----|----|\n")
			markdown.raw("|")
			try markdown.image(testImage)
			markdown.raw("| ")
			let sat = try testImage.adjustingColors(saturation: 0.3)
			try markdown.image(sat, linked: true)
			markdown.raw(" | ")
			let contr = try testImage.adjustingColors(contrast: 0.7)
			try markdown.image(contr, linked: true)
			markdown.raw(" | ")
			let bri = try testImage.adjustingColors(brightness: -0.6)
			try markdown.image(bri, linked: true)
			markdown.raw(" |\n").br()
		}
		#endif
	}

	func testClipping() throws {
		markdown.h1("Clipping to a path")

		do {
			let testImage = try loadImage(name: "wilsonsprom", extn: "jpeg") //.scaling(by: 0.5)

			let bezierPath = CGMutablePath()
			bezierPath.move(to: CGPoint(x: 1144, y: 251))
			bezierPath.addCurve(to: CGPoint(x: 913.61, y: 22), control1: CGPoint(x: 1144, y: 124.53), control2: CGPoint(x: 1040.85, y: 22))
			bezierPath.addCurve(to: CGPoint(x: 749.5, y: 90.28), control1: CGPoint(x: 849.38, y: 22), control2: CGPoint(x: 791.28, y: 48.13))
			bezierPath.addCurve(to: CGPoint(x: 585.39, y: 22), control1: CGPoint(x: 707.72, y: 48.13), control2: CGPoint(x: 649.62, y: 22))
			bezierPath.addCurve(to: CGPoint(x: 355, y: 251), control1: CGPoint(x: 458.15, y: 22), control2: CGPoint(x: 355, y: 124.53))
			bezierPath.addCurve(to: CGPoint(x: 469.03, y: 448.69), control1: CGPoint(x: 355, y: 335.28), control2: CGPoint(x: 400.81, y: 408.93))
			bezierPath.addCurve(to: CGPoint(x: 585.39, y: 480), control1: CGPoint(x: 503.18, y: 468.59), control2: CGPoint(x: 542.94, y: 480))
			bezierPath.addCurve(to: CGPoint(x: 749.5, y: 411.72), control1: CGPoint(x: 649.62, y: 480), control2: CGPoint(x: 707.72, y: 453.87))
			bezierPath.addCurve(to: CGPoint(x: 913.61, y: 480), control1: CGPoint(x: 791.28, y: 453.87), control2: CGPoint(x: 849.38, y: 480))
			bezierPath.addCurve(to: CGPoint(x: 1144, y: 251), control1: CGPoint(x: 1040.85, y: 480), control2: CGPoint(x: 1144, y: 377.47))
			bezierPath.closeSubpath()

			let clipped = try testImage.clipping(to: bezierPath)
			try markdown.image(clipped, linked: true)
		}

		do {
			let testImage = try loadImage(name: "wilsonsprom", extn: "jpeg") //.scaling(by: 0.5)
			let clipped = try testImage.clipping(to: CGPath(rect: CGRect(x: 0, y: 0, width: 400, height: 400), transform: nil))
			try markdown.image(clipped, linked: true)
		}

		markdown.br()
	}

	func testColorspaceConversion() throws {
		try markdown.h1("Colorspace conversion") { markdown in
			try markdown.h2("Image without alpha") { markdown in
				let testImage = try self.loadImage(name: "wilsonsprom", extn: "jpeg")
				let cmyk = try testImage.convertToCMYK()
				markdown.raw("| Original | CMYK |\n")
				markdown.raw("|------|------|\n")
				markdown.raw("|")
				try markdown.image(testImage, linked: true)
				markdown.raw("| ")
				try markdown.image(cmyk, linked: true)
				markdown.raw(" | ").br()
			}

			try markdown.h2("Image with alpha") { markdown in
				let testImageAlpha = try self.loadImage(name: "apple-logo-dark", extn: "png")
				let cmyk = try testImageAlpha.convertToCMYK()

				markdown.raw("| Original | CMYK |\n")
				markdown.raw("|------|------|\n")
				markdown.raw("|")
				try markdown.image(testImageAlpha, linked: true)
				markdown.raw("| ")
				try markdown.image(cmyk, linked: true)
				markdown.raw(" | ").br()
			}
		}
	}

	func testCMYKLoading() throws {
		try markdown.h1("CMYK") { markdown in
			let cmykImage = try self.loadImage(name: "cmyk", extn: "jpg")
			// The loaded image will be cmyk
			XCTAssertEqual(cmykImage.colorSpace?.model, CGColorSpaceModel.cmyk)

			do {
				// Check that we write out CMYK data for jpegs (png doesn't support)
				let jpegCMYKData = try cmykImage.jpegData()
				let reloadedCMYKImage = try WCGImage(data: jpegCMYKData)
				XCTAssertEqual(reloadedCMYKImage.colorSpace?.model, CGColorSpaceModel.cmyk)
			}

			markdown.raw("| loaded (cmyk) | CMYK |\n")
			markdown.raw("|------|------|\n")
			markdown.raw("|")

			try markdown.image(cmykImage, width: 250, linked: true)
			markdown.raw("|")

			// The new image should be sRGB (operations always end up with an sRGB image)
			let s1 = try cmykImage.scaling(by: 0.5)
			XCTAssertEqual(s1.colorSpace?.model, CGColorSpaceModel.rgb)
			try markdown.image(s1)
			markdown.raw("|")
			markdown.br()
		}
	}

	func testMasking() throws {
		markdown.h2("Masking")

		markdown.raw("| original image | mask | result |\n")
		markdown.raw("|------|------|--------|\n")
		markdown.raw("|")

		let cmykImage = try loadImage(name: "cmyk", extn: "jpg")
		try markdown.image(cmykImage, linked: true).raw(" | ")

		let maskImage = try loadImage(name: "cat-icon", extn: "png")
		try markdown.image(maskImage, linked: true).raw(" | ")

		let masked = try cmykImage.masking(to: maskImage)
		try markdown.image(masked, linked: true).raw(" | ")

		markdown.br()
	}
}
