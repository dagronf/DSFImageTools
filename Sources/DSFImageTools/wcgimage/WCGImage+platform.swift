//
//  WCGImage+platform.swift
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

// MARK: [Platform-specific exporting]

public extension WCGImage {
#if os(macOS)
	/// Create via NSImage
	/// - Parameter image: The image
	convenience init(_ image: NSImage) throws {
		guard let image = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { throw ErrorType.invalidImage }
		try self.init(image: image)
	}

	/// Create an image from data
	/// - Parameter data: The data to create from
	convenience init(data: Data) throws {
		guard let image = NSImage(data: data) else { throw ErrorType.invalidImage }
		try self.init(image)
	}
#else
	/// Create via UIImage
	/// - Parameter image: The image
	convenience init(_ image: UIImage) throws {
		guard let image = image.cgImage else { throw ErrorType.invalidImage }
		try self.init(image: image)
	}

	/// Create an image from data
	/// - Parameter data: The data to create from
	convenience init(data: Data) throws {
		guard let image = UIImage(data: data) else { throw ErrorType.invalidImage }
		try self.init(image)
	}
#endif
}

public extension WCGImage {
#if os(macOS)
	/// Return an NSImage representation of this image
	@inlinable func platformImage() throws -> NSImage {
		guard let image = self._owned else { throw ErrorType.invalidImage }
		return NSImage(cgImage: image, size: .zero)
	}
#else
	/// Return a UIImage representation of this image
	@inlinable func platformImage() throws -> UIImage {
		guard let image = self._owned else { throw ErrorType.invalidImage }
		return UIImage(cgImage: image)
	}
#endif
}
