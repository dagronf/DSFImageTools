@testable import DSFImageTools
import XCTest

@available(macOS 10.13, iOS 13.0, tvOS 13.0, *)
final class CGColorTests: XCTestCase {
	func testCGColorHex() throws {
		do {
			let hc = try XCTUnwrap(CGColor.fromHexString("#FF25EE"))
			let co = try XCTUnwrap(hc.components)
			XCTAssertEqual(WCGDefaultHexColorSpace.name, hc.colorSpace?.name)
			XCTAssertEqual(co[0], 1, accuracy: 0.000001)
			XCTAssertEqual(co[1], 0.145098, accuracy: 0.000001)
			XCTAssertEqual(co[2], 0.933333, accuracy: 0.000001)
			XCTAssertEqual(co[3], 1, accuracy: 0.000001)
		}

		do {
			let hc = try XCTUnwrap(CGColor.fromHexString("FF25ee"))
			let co = try XCTUnwrap(hc.components)
			XCTAssertEqual(WCGDefaultHexColorSpace.name, hc.colorSpace?.name)
			XCTAssertEqual(co[0], 1, accuracy: 0.000001)
			XCTAssertEqual(co[1], 0.145098, accuracy: 0.000001)
			XCTAssertEqual(co[2], 0.933333, accuracy: 0.000001)
			XCTAssertEqual(co[3], 1, accuracy: 0.000001)
		}

		do {
			let hc = try XCTUnwrap(CGColor.fromHexString("#00112244"))
			let co = try XCTUnwrap(hc.components)
			XCTAssertEqual(WCGDefaultHexColorSpace.name, hc.colorSpace?.name)
			XCTAssertEqual(co[0], 0, accuracy: 0.000001)
			XCTAssertEqual(co[1], 0.066666, accuracy: 0.000001)
			XCTAssertEqual(co[2], 0.133333, accuracy: 0.000001)
			XCTAssertEqual(co[3], 0.266666, accuracy: 0.000001)

			let hcs = try XCTUnwrap(hc.hexRGB256)
			XCTAssertEqual("#001122", hcs)

			let hcsa = try XCTUnwrap(hc.hexRGBA256)
			XCTAssertEqual("#00112244", hcsa)
		}

		do {
			let hc = try XCTUnwrap(CGColor.fromHexString("ff25eeAA"))
			let co = try XCTUnwrap(hc.components)
			XCTAssertEqual(WCGDefaultHexColorSpace.name, hc.colorSpace?.name)
			XCTAssertEqual(co[0], 1, accuracy: 0.000001)
			XCTAssertEqual(co[1], 0.145098, accuracy: 0.000001)
			XCTAssertEqual(co[2], 0.933333, accuracy: 0.000001)
			XCTAssertEqual(co[3], 0.666666, accuracy: 0.000001)

			let hcs = try XCTUnwrap(hc.hexRGB256)
			XCTAssertEqual("#ff25ee", hcs)
			let hcsa = try XCTUnwrap(hc.hexRGBA256)
			XCTAssertEqual("#ff25eeaa", hcsa)
		}
	}
}
