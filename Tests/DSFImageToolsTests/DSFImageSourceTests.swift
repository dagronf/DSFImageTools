@testable import DSFImageTools
import XCTest

private let markdown = MarkdownGenerator()

private func bundleResourceURL(forResource name: String, withExtension ext: String) -> URL {
	return Bundle.module.url(forResource: name, withExtension: ext)!
}

final class DSFImageSourceTests: XCTestCase {

	override class func tearDown() {
		super.tearDown()

		let destination = try! tempContainer.testFilenameWithName("dsfimagesource.markdown")
		try! markdown.write(to: destination)
	}

	func testValidBundleResourcesCanBeLoaded() throws {
		let imgURL = try XCTAssertUnwrap(Bundle.module.url(forResource: "hulk", withExtension: "gif"))
		let img2URL = try XCTAssertUnwrap(Bundle.module.url(forResource: "Portrait_5", withExtension: "jpg"))
#if os(macOS)
		XCTAssertNoThrow(try NSImage(data: Data(contentsOf: imgURL)))
		XCTAssertNoThrow(try NSImage(data: Data(contentsOf: img2URL)))
#else
		XCTAssertNoThrow(try UIImage(data: Data(contentsOf: imgURL)))
		XCTAssertNoThrow(try UIImage(data: Data(contentsOf: img2URL)))
#endif
	}

	func testCheckImagesCanBeLoaded() throws {

		markdown.h1("GIF content")

		markdown.raw("|  1  |  2  |  3  |  4  |\n")
		markdown.raw("|-----|-----|-----|-----|\n")
		markdown.raw("| ")

		let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "gif")
		let image = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		XCTAssertEqual(image.count, 4)
		var count = 0
		try image.forEach { subimage in
			let si = try XCTUnwrap(subimage.image)
			count += 1
			try markdown.image(si)
			markdown.raw("| ")
		}
		markdown.raw("| \n")

		// Verify we looped exactly 4 times
		XCTAssertEqual(4, count)

		markdown.br()
	}

	func testImageSubscript() throws {
		let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "gif")
		let image = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		XCTAssertEqual(image.count, 4)
		XCTAssertNil(image[-1]?.image)
		XCTAssertNotNil(image[0]?.image)
		XCTAssertNotNil(image[1]?.image)
		XCTAssertNotNil(image[2]?.image)
		XCTAssertNotNil(image[3]?.image)
		XCTAssertNil(image[4]?.image)
		XCTAssertNil(image[5]?.image)

		let props = try XCTAssertUnwrap(image[1]?.gifProperties)
		XCTAssertEqual(props.count, 2)
	}

	func testOrientation() throws {

		markdown.h1("Orientation")

		let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "gif")
		let image = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		let orientation = image[0]!.orientation
		XCTAssertEqual(.up, orientation) // no orientation specified

		markdown.raw("| original | orientation removed |\n")
		markdown.raw("|----|----|\n")
		markdown.raw("|")

		let img2URL = bundleResourceURL(forResource: "Portrait_5", withExtension: "jpg")
		let image2 = try XCTAssertUnwrap(DSFImageSource(fileURL: img2URL))
		let firstImage = try XCTUnwrap(image2[0])
		let orientation2 = firstImage.orientation
		let image22 = try XCTUnwrap(firstImage.image)
		XCTAssertEqual(.leftMirrored, orientation2)
		try markdown.image(image22).raw(" | ")

		// Remove the orientation

		let removedOrientationCGImage = try XCTAssertUnwrap(image2[0]!.removingOrientation())
		XCTAssertEqual(CGFloat(removedOrientationCGImage.width), image2[0]!.pixelSize.height)
		XCTAssertEqual(CGFloat(removedOrientationCGImage.height), image2[0]!.pixelSize.width)

		let image222 = try XCTUnwrap(removedOrientationCGImage)
		try markdown.image(image222).raw(" | ").br()
	}

	#if !os(tvOS)
	func testThumbnailGeneration() throws {

		let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "gif")

		let image = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		XCTAssertEqual(4, image.count)
		_ = try XCTAssertUnwrap(image[0]?.thumbnailImage(maxThumbnailSize: 300))
		_ = try XCTAssertUnwrap(image[1]?.thumbnailImage(maxThumbnailSize: 300))
		_ = try XCTAssertUnwrap(image[2]?.thumbnailImage(maxThumbnailSize: 300))

		let expectation = expectation(description: "Wait for a thumbnail to be generated")

		DSFFileThumbnail.Generate(
			for: imgURL,
				ofSize: CGSize(width: 256, height: 256)
		) { thumbnail in
			if let i = thumbnail?.image {
				Swift.print(i)
			}
			expectation.fulfill()
		}

		waitForExpectations(timeout: 3) { error in
			XCTAssertNil(error)
		}
	}
	#endif

	func testExtractImage() throws {
		let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "gif")
		let image = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		XCTAssertEqual(4, image.count)

		let data1 = try XCTAssertUnwrap(image[1]?.imageData(utiType: "public.jpeg"))
		XCTAssertNotNil(data1)

		// Check that an unknown/unsupported uti type returns a nil value
		let data2 = image[1]?.imageData(utiType: "public.unknwon")
		XCTAssertNil(data2)

		let data3 = try XCTAssertUnwrap(image[1]?.imageData(utiType: "public.jpeg-2000"))
		XCTAssertNotNil(data3)

		let data4 = try XCTAssertUnwrap(image[1]?.imageData(utiType: "public.jpeg", compression: 0.1))
		XCTAssertNotNil(data4)
	}

	func testCompressionLevels() throws {

		markdown.h1("Compression")

		let imgURL = bundleResourceURL(forResource: "Portrait_5", withExtension: "jpg")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		let image = try XCTAssertUnwrap(imageSource[0])

		markdown.raw("|  1.0  |  0.6  |  0.3  |  0.0  |\n")
		markdown.raw("|:-----:|:-----:|:-----:|:-----:|\n")

		markdown.raw("|")
		let data1 = try XCTAssertUnwrap(image.imageData(type: .jpeg, compression: 1.0))
		try markdown.image(try WCGImage(data: data1)).raw("<br/>")
		markdown.raw("\(data1.count) |")

		let data2 = try XCTAssertUnwrap(image.imageData(type: .jpeg, compression: 0.6))
		try markdown.image(try WCGImage(data: data2)).raw("<br/>")
		markdown.raw("\(data2.count) |")
		let data3 = try XCTAssertUnwrap(image.imageData(type: .jpeg, compression: 0.3))
		try markdown.image(try WCGImage(data: data3)).raw("<br/>")
		markdown.raw("\(data3.count) |")
		let data4 = try XCTAssertUnwrap(image.imageData(type: .jpeg, compression: 0.0))
		try markdown.image(try WCGImage(data: data4)).raw("<br/>")
		markdown.raw("\(data4.count) |")

		XCTAssertGreaterThan(data1.count, data2.count)
		XCTAssertGreaterThan(data2.count, data3.count)
		XCTAssertGreaterThan(data3.count, data4.count)

		markdown.br()
	}

	func testGetGPSCoordinates1() throws {
		let imgURL = bundleResourceURL(forResource: "gps-coordinates", withExtension: "jpg")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))

		let coords = try XCTAssertUnwrap(imageSource.location)
		Swift.print(coords)
		Swift.print("\(coords.latitudeDMS), \(coords.longitudeDMS)")
		XCTAssertEqual(43.468365, coords.latitude.value, accuracy: 0.0001)
		XCTAssertEqual(11.881635, coords.longitude.value, accuracy: 0.0001)
		XCTAssertEqual("N", coords.latitude.reference)
		XCTAssertEqual("E", coords.longitude.reference)
	}

	func testGetGPSCoordinates2() throws {
		let imgURL = bundleResourceURL(forResource: "gps-image", withExtension: "jpg")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))

		let coords = try XCTAssertUnwrap(imageSource.location)
		Swift.print(coords)
		Swift.print("\(coords.latitudeDMS), \(coords.longitudeDMS)")
		XCTAssertEqual(33.8506666, coords.latitude.value, accuracy: 0.0001)
		XCTAssertEqual(151.212833, coords.longitude.value, accuracy: 0.0001)
		XCTAssertEqual("S", coords.latitude.reference)
		XCTAssertEqual("E", coords.longitude.reference)
	}

	func testExport() throws {
		let imgURL = bundleResourceURL(forResource: "gps-image", withExtension: "jpg")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))

		let exportData1 = try XCTAssertUnwrap(imageSource.data(imageType: .tiff))
		let importData1 = try XCTAssertUnwrap(DSFImageSource(data: exportData1))

		XCTAssertEqual(importData1.type, "public.tiff")
	}

	func testExportGPS() throws {
		let imgURL = bundleResourceURL(forResource: "gps-image", withExtension: "jpg")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))

		// Export and keep location information
		let exportData1 = try XCTAssertUnwrap(imageSource.data(imageType: .jpeg, removeGPSData: true))
		let importData1 = try XCTAssertUnwrap(DSFImageSource(data: exportData1))
		XCTAssertNil(importData1.location)

		// Export and remove the location information
		let exportData2 = try XCTAssertUnwrap(imageSource.data(imageType: .jpeg, removeGPSData: false))
		let importData2 = try XCTAssertUnwrap(DSFImageSource(data: exportData2))
		XCTAssertNotNil(importData2.location)
	}

	func testMultipage() throws {
		let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "gif")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		XCTAssertEqual(4, imageSource.count)

		let exportData1 = try XCTAssertUnwrap(imageSource.data(imageType: .tiff))
		let importData1 = try XCTAssertUnwrap(DSFImageSource(data: exportData1))
		XCTAssertEqual(4, importData1.count)
	}

	func testGifImportExport() throws {
		let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "gif")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		XCTAssertEqual(4, imageSource.count)

		let exportData1 = try XCTAssertUnwrap(imageSource.data(imageType: .gif))
		let importData1 = try XCTAssertUnwrap(DSFImageSource(data: exportData1))
		XCTAssertEqual(DSFImageSourceType.gif.rawValue, importData1.type)
		XCTAssertNotEqual(DSFImageSourceType.jpeg.rawValue, importData1.type)
		XCTAssertEqual(4, importData1.count)
	}

	func testBuildFromImages() throws {
		let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "gif")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		XCTAssertEqual(4, imageSource.count)
		let initialSize = imageSource[0]!.pixelSize

		let imgURL2 = bundleResourceURL(forResource: "gps-image", withExtension: "jpg")
		let imageSource2 = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL2))
		XCTAssertEqual(1, imageSource2.count)
		let initialSize2 = imageSource2[0]!.pixelSize

		var cgImages = imageSource.cgImages
		XCTAssertEqual(4, cgImages.count)

		cgImages.append(imageSource2[0]!.image!)

		let built = try XCTAssertUnwrap(DSFImageSource(images: cgImages))
		XCTAssertEqual(5, built.count)

		XCTAssertEqual(initialSize, built[0]?.pixelSize)
		XCTAssertEqual(initialSize, built[1]?.pixelSize)
		XCTAssertEqual(initialSize, built[2]?.pixelSize)
		XCTAssertEqual(initialSize, built[3]?.pixelSize)
		XCTAssertEqual(initialSize2, built[4]?.pixelSize)

		_ = try XCTAssertUnwrap(built[0]?.thumbnail())
		_ = try XCTAssertUnwrap(built[1]?.thumbnail())
		_ = try XCTAssertUnwrap(built[2]?.thumbnail())
		_ = try XCTAssertUnwrap(built[3]?.thumbnail())
	}

	func testBuilder() throws {
		let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "gif")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		XCTAssertEqual(4, imageSource.count)

		let imgURL2 = bundleResourceURL(forResource: "gps-image", withExtension: "jpg")
		let imageSource2 = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL2))
		XCTAssertEqual(1, imageSource2.count)

		let combined = DSFImageSource.Build(images: imageSource.cgImages + imageSource2.cgImages, type: .tiff)
		let builtImageSource = try XCTAssertUnwrap(combined)
		XCTAssertEqual(5, builtImageSource.count)
	}

	func testLoadHEIC() throws {
		let imgURL = bundleResourceURL(forResource: "DSCN0012", withExtension: "heic")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		XCTAssertEqual(imageSource.type, DSFImageSourceType.heic.rawValue)
		XCTAssertEqual(1, imageSource.count)
		XCTAssertNotNil(imageSource.location)
	}

	func testHEIC() throws {
		let imgURL = bundleResourceURL(forResource: "gps-image", withExtension: "jpg")
		let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
		XCTAssertEqual(1, imageSource.count)

		let imageData = try XCTAssertUnwrap(imageSource.data(imageType: .heic, removeGPSData: false))
		let imageSource2 = try XCTAssertUnwrap(DSFImageSource(data: imageData))
		XCTAssertEqual(imageSource2.type, DSFImageSourceType.heic.rawValue)
		XCTAssertNotNil(imageSource2.location)

		do {
			let f = try XCTTemporaryFile(prefix: "dummy", fileExtension: "heic", contents: imageData)
			Swift.print(f.fileURL)
		}
	}

	func testDPI() throws {
		try markdown.h1("DPI") { markdown in

			markdown.raw("| 72 dpi | 300 dpi |\n")
			markdown.raw("|:------:|:-------:|\n")
			markdown.raw("|")
			do {
				let imgURL = bundleResourceURL(forResource: "gps-image", withExtension: "jpg")
				let imageSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
				XCTAssertEqual(1, imageSource.count)
				let image72dpi = try XCTAssertUnwrap(imageSource[0])
				XCTAssertEqual(image72dpi.dpi, CGSize(width: 72, height: 72))
				try markdown.imageData(try Data(contentsOf: imgURL), extn: "jpg")
				markdown.raw("<br/> Validated -> \(image72dpi.dpi) |")
			}

			do {
				let imgURL2 = bundleResourceURL(forResource: "gps-coordinates", withExtension: "jpg")
				let imageSource2 = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL2))
				XCTAssertEqual(1, imageSource2.count)
				let image300dpi = try XCTAssertUnwrap(imageSource2[0])
				XCTAssertEqual(image300dpi.dpi, CGSize(width: 300, height: 300))
				try markdown.imageData(try Data(contentsOf: imgURL2), extn: "jpg")
				markdown.raw("<br/> Validated -> \(image300dpi.dpi) |")
			}
		}
		markdown.br()
	}

	#if os(macOS)
	func testNSImage() throws {

		do {
			let imgURL = bundleResourceURL(forResource: "gps-image", withExtension: "jpg")
			let origSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
			let image = try XCTAssertUnwrap(NSImage(contentsOf: imgURL))

			let imageSource = try XCTAssertUnwrap(DSFImageSource(image: image))
			XCTAssertEqual(1, imageSource.count)
			XCTAssertEqual(origSource.count, imageSource.count)
		}

		do {
			let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "gif")
			let origSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
			let image = try XCTAssertUnwrap(NSImage(contentsOf: imgURL))

			let imageSource = try XCTAssertUnwrap(DSFImageSource(image: image))
			XCTAssertEqual(4, imageSource.count)
			XCTAssertEqual(origSource.count, imageSource.count)
		}

		do {
			let imgURL = bundleResourceURL(forResource: "hulk", withExtension: "heic")
			let image = try XCTAssertUnwrap(NSImage(contentsOf: imgURL))
			let origSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))

			let imageSource = try XCTAssertUnwrap(DSFImageSource(image: image))
			XCTAssertEqual(4, imageSource.count)
			XCTAssertEqual(origSource.count, imageSource.count)
		}

		do {
			let imgURL = bundleResourceURL(forResource: "multipage_tiff_example", withExtension: "tif")
			let origSource = try XCTAssertUnwrap(DSFImageSource(fileURL: imgURL))
			let image = try XCTAssertUnwrap(NSImage(contentsOf: imgURL))

			let imageSource = try XCTAssertUnwrap(DSFImageSource(image: image))
			XCTAssertEqual(10, imageSource.count)
			XCTAssertEqual(origSource.count, imageSource.count)
		}
	}
	#endif
}
