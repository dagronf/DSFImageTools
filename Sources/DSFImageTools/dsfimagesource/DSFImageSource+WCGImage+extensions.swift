//
//  DSFImageSource+WCGImage+extensions.swift
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

import Foundation
import CoreGraphics
import ImageIO

public extension DSFImageSource {
	/// Create an image source from a WCGImage
	convenience init?(image: WCGImage) {
		guard let image = try? image.cgImage() else {
			return nil
		}
		self.init(cgImage: image)
	}

	/// Returns a WCGImage object with a copy of the image at the specified index
	func wcgImage(at index: Int) -> WCGImage? {
		guard
			let image = self[index],
			let cgimage = image.image?.copy()
		else {
			return nil
		}
		return try? WCGImage(image: cgimage)
	}
}

public extension DSFImageSource.Builder {

	/// Append an image to the collection of images using the specified compression level
	@inlinable func add(_ image: WCGImage, compressionLevel: CGFloat) throws {
		try self.add(image, properties: [kCGImageDestinationLossyCompressionQuality as String: compressionLevel])
	}

	/// Add an image using the specified images properties
	/// - Parameters:
	///   - image: The image to add
	///   - properties: An optional dictionary that specifies the properties of the added image. The dictionary can contain any of the
	///                 properties described in [Destination Properties](https://developer.apple.com/documentation/imageio/cgimagedestination/destination_properties)
	///                 or the image properties described in [CGImageProperties](https://developer.apple.com/documentation/imageio/cgimageproperties).
	func add(_ image: WCGImage, properties: [String: Any]? = nil) throws {
		self.images.append((try image.cgImage(), properties))
	}
}
