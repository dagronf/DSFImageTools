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

// MARK: - Color conveniences

@objc public class WCGColor: NSObject {
#if os(macOS)
	/// Clear color
	@objc public static let clear: CGColor = .clear
	/// Black color
	@objc public static let black: CGColor = .black
	/// White color
	@objc public static let white: CGColor = .white
	/// Gray color
	@objc public static let gray = NSColor.gray.cgColor
#else
	/// Clear color
	@objc public static let clear = UIColor.clear.cgColor
	/// Black color
	@objc public static let black = UIColor.black.cgColor
	/// White color
	@objc public static let white = UIColor.white.cgColor
	/// Gray color
	@objc public static let gray = UIColor.gray.cgColor
#endif
}

