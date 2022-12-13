//
//  WCGColor.swift
//
//  Copyright © 2022 Darren Ford. All rights reserved.
//
//  MIT License
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all
//  copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
//  SOFTWARE.

import CoreGraphics
import Foundation

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// The default colorspace for hex (standard RGB)
public let WCGDefaultHexColorSpace = CGColorSpace(name: CGColorSpace.sRGB)!

// MARK: - Color conveniences

@objc public class WCGColor: NSObject {
#if os(macOS)
	/// Clear color
	@objc public static let clear: CGColor = .clear
	/// Black color
	@objc public static let black: CGColor = .black
	/// White color
	@objc public static let white: CGColor = .white
#else
	/// Clear color
	@objc public static let clear = UIColor.clear.cgColor
	/// Black color
	@objc public static let black = UIColor.black.cgColor
	/// White color
	@objc public static let white = UIColor.white.cgColor
#endif

	/// Create a CGColor color from a hex string
	/// - Parameters:
	///   - hexString: The hex string representing the color
	///   - colorSpace: The colorspace to use (expecting RGBA). Defaults to sRGB.
	/// - Returns: The color, or nil if the color couldn't be created
	///
	/// Usage:
	///
	/// ```swift
	///   let color = WCGColor.hex("#A1B2C3FF")
	/// ```
	///
	/// Supported formats:
	/// * [#]fff (rgb, alpha = 1)
	/// * [#]ffff (rgba)
	/// * [#]ffffff (rgb, alpha = 1)
	/// * [#]ffffffff (rgba)
	@objc @inlinable public static func hex(
		_ hexString: String,
		usingColorSpace colorSpace: CGColorSpace = WCGDefaultHexColorSpace
	) -> CGColor? {
		CGColor.fromHexString(hexString, usingColorSpace: colorSpace)
	}
}

extension CGColor {
	/// Create a CGColor color from a hex string
	/// - Parameters:
	///   - hexString: The hex string representing the color
	///   - colorSpace: The colorspace to use (expecting RGBA). Defaults to sRGB.
	/// - Returns: The color, or nil if the color couldn't be created
	///
	/// Usage:
	///
	/// ```swift
	///   let color = CGColor.fromHexString("#A1B2C3FF")
	/// ```
	///
	/// Supported formats:
	/// * [#]fff (rgb, alpha = 1)
	/// * [#]ffff (rgba)
	/// * [#]ffffff (rgb, alpha = 1)
	/// * [#]ffffffff (rgba)
	@inlinable public static func fromHexString(
		_ hexString: String,
		usingColorSpace colorSpace: CGColorSpace = WCGDefaultHexColorSpace
	) -> CGColor? {
		var string = hexString.lowercased()
		if hexString.hasPrefix("#") {
			string = String(string.dropFirst())
		}
		switch string.count {
		case 3:
			string += "f"
			fallthrough
		case 4:
			let chars = Array(string)
			let red = chars[0]
			let green = chars[1]
			let blue = chars[2]
			let alpha = chars[3]
			string = "\(red)\(red)\(green)\(green)\(blue)\(blue)\(alpha)\(alpha)"
		case 6:
			string += "ff"
		case 8:
			break
		default:
			return nil
		}

		guard let rgba = Double("0x" + string)
			.flatMap( {UInt32(exactly: $0) } )
		else {
			return nil
		}
		let red = Double((rgba & 0xFF00_0000) >> 24) / 255
		let green = Double((rgba & 0x00FF_0000) >> 16) / 255
		let blue = Double((rgba & 0x0000_FF00) >> 8) / 255
		let alpha = Double((rgba & 0x0000_00FF) >> 0) / 255

		return CGColor(colorSpace: colorSpace, components: [red, green, blue, alpha])
	}
}
