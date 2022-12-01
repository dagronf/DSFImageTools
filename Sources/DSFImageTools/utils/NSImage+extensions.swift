//
//  NSImage+extensions.swift
///  Copyright © 2022 Darren Ford. All rights reserved.
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

// Some conveniences for NSImage (macOS only)

#if os(macOS)

import Foundation
import AppKit

extension NSImage {
	/// Create a RGBA NSImage by drawing into it
	/// - Parameters:
	///   - size: The size of the image to create
	///   - dpi: The DPI for the resluting NSImage (72 == 1x, 144 == 2x, 216 == 3x etc)
	///   - isTemplate: Generate a template image
	///   - drawBlock: The drawing block
	/// - Returns: A new NSImage
	static func CreateByDrawingIntoContext(
		size: CGSize,
		dpi: CGFloat = 72,
		isTemplate: Bool = false,
		_ drawBlock: ((CGContext, CGSize) -> Void)? = nil
	) throws -> NSImage {
		let scale = dpi / 72.0
		let coreSize = CGSize(width: size.width * scale, height: size.height * scale)
		let image = try WCGImage.Create(size: coreSize, drawBlock)
		let i = NSImage(cgImage: image, size: size)
		i.isTemplate = isTemplate
		return i
	}
}

#endif
