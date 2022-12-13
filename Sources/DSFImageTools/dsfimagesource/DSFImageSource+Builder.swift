//
//  DSFImageSource+Builder.swift
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
import ImageIO

private let __MultiTypes: [String] = [
	DSFImageSourceType.tiff.rawValue,
	DSFImageSourceType.gif.rawValue,
]

// MARK: - Building an image source from images

public extension DSFImageSource {
	/// Convenience static method for building an image source from a series of images
	@inlinable static func Build(images: [CGImage], type: DSFImageSourceType, compressionLevel: CGFloat = 1.0) -> DSFImageSource? {
		return Builder.Build(images: images, type: type, compressionLevel: compressionLevel)
	}
}

// MARK: - A builder object for building an image source

public extension DSFImageSource {
	/// A builder object for composing a new image source from individual images
	@objc class Builder: NSObject {
		internal var images: [(CGImage, [String: Any]?)] = []
		
		/// Initializer
		@objc override public init() {
			super.init()
		}
		
		/// The number of images in the builder
		@objc public var count: Int { self.images.count }
		
		/// Convenience for creating an image source from a collection of images. The compression level applies to all images in the collection
		public init(images: [CGImage], compressionLevel: CGFloat = 1.0) {
			self.images = images.compactMap { ($0, [kCGImageDestinationLossyCompressionQuality as String: compressionLevel]) }
			super.init()
		}
		
		/// Append an image to the collection of images using the specified compression level
		@objc @inlinable public func add(_ image: CGImage, compressionLevel: CGFloat) {
			self.add(image, properties: [kCGImageDestinationLossyCompressionQuality as String: compressionLevel])
		}
		
		/// Add an image using the specified images properties
		/// - Parameters:
		///   - image: The image to add
		///   - properties: An optional dictionary that specifies the properties of the added image. The dictionary can contain any of the
		///                 properties described in [Destination Properties](https://developer.apple.com/documentation/imageio/cgimagedestination/destination_properties)
		///                 or the image properties described in [CGImageProperties](https://developer.apple.com/documentation/imageio/cgimageproperties).
		@objc public func add(_ image: CGImage, properties: [String: Any]? = nil) {
			self.images.append((image, properties))
		}
		
		/// Make an image source using the specified image file type
		@inlinable public func build(type: DSFImageSourceType) -> DSFImageSource? {
			return self.build(utiType: type.rawValue)
		}
		
		/// Make an image source using the specified image file type
		@objc public func build(utiType: String) -> DSFImageSource? {
			guard self.images.count > 0 else { return nil }
			if self.images.count > 1 {
				if __MultiTypes.contains(utiType) == false {
					Swift.print("DSFImageSource: ERROR - .tiff and .gif are the only supported types for multi images")
					return nil
				}
			}
			
			guard
				let mutableData = CFDataCreateMutable(nil, 0),
				let destination = CGImageDestinationCreateWithData(mutableData, utiType as CFString, self.images.count, nil)
			else {
				return nil
			}
			
			// Add all of the images.
			self.images.forEach { image in
				CGImageDestinationAddImage(destination, image.0, image.1 as CFDictionary?)
			}
			
			guard CGImageDestinationFinalize(destination) else {
				return nil
			}
			
			return DSFImageSource(data: mutableData as Data)
		}
	}
}

// MARK: - Conveniences for the image builder

public extension DSFImageSource.Builder {
	/// Convenience static method for building an image source from a single image
	@inlinable static func Build(image: CGImage, type: DSFImageSourceType, compressionLevel: CGFloat = 1.0, properties: [String: Any]? = nil) -> DSFImageSource? {
		let builder = DSFImageSource.Builder()
		var mprops = properties ?? [:]
		mprops[kCGImageDestinationLossyCompressionQuality as String] = compressionLevel
		builder.add(image, properties: mprops)
		return builder.build(type: type)
	}
	
	/// Convenience static method for building an image source from a series of images
	@inlinable static func Build(images: [CGImage], type: DSFImageSourceType, compressionLevel: CGFloat = 1.0) -> DSFImageSource? {
		return DSFImageSource.Builder(images: images, compressionLevel: compressionLevel).build(type: type)
	}
}
