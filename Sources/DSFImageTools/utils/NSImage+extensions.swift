//
//  NSImage+extensions.swift
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

// Some conveniences for NSImage (macOS only)

#if os(macOS)

import Foundation
import AppKit

// MARK: - CoreGraphics conveniences

extension NSImage {
	/// Create a RGBA NSImage by drawing into it using CoreGraphics
	/// - Parameters:
	///   - size: The size of the image to create
	///   - dpi: The DPI for the resluting NSImage (72 == 1x, 144 == 2x, 216 == 3x etc)
	///   - isTemplate: Generate a template image
	///   - drawBlock: The drawing block
	/// - Returns: A new NSImage
	@objc public static func CreateByDrawingIntoARGB32Context(
		size: CGSize,
		dpi: CGFloat = 72,
		isTemplate: Bool = false,
		_ drawBlock: ((CGContext, CGSize) -> Void)? = nil
	) throws -> NSImage {
		let scale = dpi / 72.0
		let coreSize = CGSize(width: size.width * scale, height: size.height * scale)
		let image = try WCGImageStatic.Create(size: coreSize, drawBlock)
		let i = NSImage(cgImage: image, size: size)
		i.isTemplate = isTemplate
		return i
	}
}

// MARK: - NSGraphicsContext conveniences

extension NSGraphicsContext {
	/// A convenience method for saving and restoring the current graphics context.
	@objc @inlinable public static func savingGState(_ drawBlock: () -> Void) {
		NSGraphicsContext.saveGraphicsState()
		defer { NSGraphicsContext.restoreGraphicsState() }
		drawBlock()
	}
}

extension NSImage {
	/// Create an image by drawing into it via a block using `NSGraphicsContext`
	/// - Parameters:
	///   - dimension: The dimension of the created image
	///   - dpi: The resulting DPI for the image
	///   - drawBlock: The block to draw on the context of the image
	/// - Returns: A new image
	@inlinable @objc public static func CreateARGB32(
		dimension: Int,
		dpi: CGFloat = 72,
		drawBlock: (NSGraphicsContext, NSSize) -> Void
	) throws -> NSImage {
		try Self.CreateARGB32(width: dimension, height: dimension, dpi: dpi, drawBlock: drawBlock)
	}

	/// Create an image by drawing into it via a block using `NSGraphicsContext`
	/// - Parameters:
	///   - width: The width in pixels for the resulting image
	///   - height: The height in pixels for the resulting image
	///   - dpi: The resulting DPI for the image
	///   - drawBlock: The block to draw on the context of the image
	/// - Returns: A new image
	@objc public static func CreateARGB32(
		width: Int,
		height: Int,
		dpi: CGFloat = 72.0,
		drawBlock: (NSGraphicsContext, NSSize) -> Void
	) throws -> NSImage {
		// The width taking into account the DPI
		let szw = width * Int((dpi / 72.0).rounded(.towardZero))
		// The height taking into account the DPI
		let szh = width * Int((dpi / 72.0).rounded(.towardZero))

		guard
			// Create the offscreen rep to draw into
			let offscreenRep = NSBitmapImageRep(
				bitmapDataPlanes: nil,
				pixelsWide: szw,
				pixelsHigh: szh,
				bitsPerSample: 8,
				samplesPerPixel: 4,
				hasAlpha: true,
				isPlanar: false,
				colorSpaceName: NSColorSpaceName.calibratedRGB,
				bytesPerRow: 0,
				bitsPerPixel: 0
			),
			let context = NSGraphicsContext(bitmapImageRep: offscreenRep)
		else {
			throw DSFImageToolsErrorType.cannotCreateImage
		}

		NSGraphicsContext.savingGState {
			// Set our bitmap context as the current graphics context
			NSGraphicsContext.current = context
			// And draw!
			drawBlock(context, NSSize(width: szw, height: szh))
		}

		let image = NSImage(size: NSSize(width: width, height: height))
		image.addRepresentation(offscreenRep)
		return image
	}
}

#endif
