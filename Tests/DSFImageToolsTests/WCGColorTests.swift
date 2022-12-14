@testable import DSFImageTools
import XCTest

final class WCGColorTests: XCTestCase {

	func testColorsRGBAConversion() throws {
		/// cmyk(100%, 31%, 0%, 24%)
		let c = CGColor(genericCMYKCyan: 1, magenta: 0.23, yellow: 0.09, black: 0.15, alpha: 1)
		let rrggbbaa = try XCTUnwrap(c.hexRGBA256)
		XCTAssertEqual("#00759cff", rrggbbaa)
	}

	func testColorsRRGGBB() throws {
		let c1 = try XCTUnwrap(CGColor.fromHexString("#Fb2801"))
		XCTAssertEqual(CGColorSpace.sRGB, c1.colorSpace?.name)
		XCTAssertEqual(4, c1.components?.count ?? 0)
		XCTAssertEqual(0.98, c1.components![0], accuracy: 0.01)
		XCTAssertEqual(0.15, c1.components![1], accuracy: 0.01)
		XCTAssertEqual(0.0039, c1.components![2], accuracy: 0.0001)
		XCTAssertEqual(1.00, c1.components![3], accuracy: 0.01)

		let rrggbb = c1.hexRGB256
		XCTAssertEqual("#fb2801", rrggbb)
		let rrggbbaa = c1.hexRGBA256
		XCTAssertEqual("#fb2801ff", rrggbbaa)
		let rgb = c1.hexRGB16
		XCTAssertEqual("#e20", rgb)
	}

	func testColorsRRGGBBAA() throws {
		let c2 = try XCTUnwrap(CGColor.fromHexString("#FF23A780"))
		XCTAssertEqual(CGColorSpace.sRGB, c2.colorSpace?.name)
		XCTAssertEqual(4, c2.components?.count ?? 0)
		XCTAssertEqual(1.0,  c2.components![0], accuracy: 0.01)
		XCTAssertEqual(0.14, c2.components![1], accuracy: 0.01)
		XCTAssertEqual(0.65, c2.components![2], accuracy: 0.01)
		XCTAssertEqual(0.5,  c2.components![3], accuracy: 0.01)

		let rrggbb = c2.hexRGB256
		XCTAssertEqual("#ff23a7", rrggbb)
		let rrggbbaa = c2.hexRGBA256
		XCTAssertEqual("#ff23a780", rrggbbaa)
		let rgb = c2.hexRGB16
		XCTAssertEqual("#f29", rgb)
	}

	func testColorsRGB() throws {
		let c3 = try XCTUnwrap(CGColor.fromHexString("#e52"))
		XCTAssertEqual(CGColorSpace.sRGB, c3.colorSpace?.name)
		XCTAssertEqual(4, c3.components?.count ?? 0)
		XCTAssertEqual(0.93, c3.components![0], accuracy: 0.01)
		XCTAssertEqual(0.33, c3.components![1], accuracy: 0.01)
		XCTAssertEqual(0.13, c3.components![2], accuracy: 0.01)
		XCTAssertEqual(1.00, c3.components![3], accuracy: 0.01)

		let rrggbb = c3.hexRGB256
		XCTAssertEqual("#ee5522", rrggbb)
		let rrggbbaa = c3.hexRGBA256
		XCTAssertEqual("#ee5522ff", rrggbbaa)
		let rgb = c3.hexRGB16
		XCTAssertEqual("#e52", rgb)
	}

	func testColorsRGBA() throws {
		let c4 = try XCTUnwrap(CGColor.fromHexString("#752B"))
		XCTAssertEqual(CGColorSpace.sRGB, c4.colorSpace?.name)
		XCTAssertEqual(4, c4.components?.count ?? 0)
		XCTAssertEqual(0.46, c4.components![0], accuracy: 0.01)
		XCTAssertEqual(0.33, c4.components![1], accuracy: 0.01)
		XCTAssertEqual(0.13, c4.components![2], accuracy: 0.01)
		XCTAssertEqual(0.73, c4.components![3], accuracy: 0.01)

		let rrggbb = c4.hexRGB256
		XCTAssertEqual("#775522", rrggbb)
		let rrggbbaa = c4.hexRGBA256
		XCTAssertEqual("#775522bb", rrggbbaa)
		let rgb = c4.hexRGB16
		XCTAssertEqual("#752", rgb)
	}

	func testContrastingColor() throws {

		let c0 = try XCTUnwrap(CGColor.fromHexString("#000"))
		let t0 = c0.contrastingTextColor()
		XCTAssertEqual(t0, WCGColor.white)

		let c00 = try XCTUnwrap(CGColor.fromHexString("#fff"))
		let t00 = c00.contrastingTextColor()
		XCTAssertEqual(t00, WCGColor.black)

		let c1 = try XCTUnwrap(CGColor.fromHexString("#f00"))
		let t1 = c1.contrastingTextColor()
		XCTAssertEqual(t1, WCGColor.black)

		let c2 = try XCTUnwrap(CGColor.fromHexString("#00f"))
		let t2 = c2.contrastingTextColor()
		XCTAssertEqual(t2, WCGColor.white)

		let c3 = try XCTUnwrap(CGColor.fromHexString("#0f0"))
		let t3 = c3.contrastingTextColor()
		XCTAssertEqual(t3, WCGColor.black)

		let c4 = try XCTUnwrap(CGColor.fromHexString("#080"))
		let t4 = c4.contrastingTextColor()
		XCTAssertEqual(t4, WCGColor.white)
	}
}
