//
//  DSFImageSource.swift
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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// Predefined image source types
public enum DSFImageSourceType: String {
	case png = "public.png"
	case jpeg = "public.jpeg"
	case tiff = "public.tiff"
	case heic = "public.heic"
	case gif = "com.compuserve.gif"
	case bmp = "com.microsoft.bmp"
}

/// A wrapper for the CGImageSource Foundation type
@objc public class DSFImageSource: NSObject {
	/// The underlying CGImageSource object
	@objc public let imageSource: CGImageSource
	
	/// Create using a CGImageSource
	@objc public init(imageSource: CGImageSource) {
		self.imageSource = imageSource
	}
	
	/// Create with the contents of the specified file URL.
	@objc public init?(fileURL: URL) {
		guard let cgiSrc = CGImageSourceCreateWithURL(fileURL as CFURL, nil) else {
			return nil
		}
		self.imageSource = cgiSrc
	}
	
	/// Create with the specified data. If the data is not valid image data, returns nil
	@objc public init?(data: Data) {
		guard let source = CGImageSourceCreateWithData(data as CFData, nil) else {
			return nil
		}
		self.imageSource = source
	}

	#if os(macOS)
	/// Create an image source from an NSImage
	@objc public init?(image: NSImage) {
		guard let source = Self.Convert(image) else {
			return nil
		}
		self.imageSource = source
	}
	#endif
	
	/// Create an image source from a CGImage
	@objc public init?(cgImage: CGImage) {
		guard
			let mutableData = CFDataCreateMutable(nil, 0),
			let destination = CGImageDestinationCreateWithData(mutableData, cgImage.utType ?? (DSFImageSourceType.tiff as! CFString), 1, nil)
		else {
			return nil
		}
		CGImageDestinationAddImage(destination, cgImage, nil)
		
		guard
			CGImageDestinationFinalize(destination),
			let s = CGImageSourceCreateWithData(mutableData, nil)
		else {
			return nil
		}
		self.imageSource = s
	}
	
	/// Returns the uniform type identifier of the source container.
	@inlinable public var type: String? {
		CGImageSourceGetType(self.imageSource) as String?
	}
	
	// MARK: - Accessing images
	
	/// Returns the number of images (not including thumbnails) in the image source.
	@inlinable public var count: Int {
		CGImageSourceGetCount(self.imageSource)
	}
	
	/// Returns the image at the specified index
	public subscript(index: Int) -> DSFImageSource.Image? {
		if index < self.count { return Image(self, index: index) }
		return nil
	}
	
	// MARK: - GPS informration
	
	/// Returns the GPS coordinates for the image
	@objc @inlinable public var location: DSFImageSource.GPSCoordinates? {
		for index in 0 ..< self.count {
			if let data = self[index]?.location {
				return data
			}
		}
		return nil
	}
	
	/// Returns true if any of the representations has gps coordinates
	@objc @inlinable public var hasLocation: Bool {
		return self.location != nil
	}
}

// MARK: - Create an imagesource from multiple images

public extension DSFImageSource {
	/// Make an image source using the contents of the specified images
	/// - Parameters:
	///   - images: The images to include in the source
	///   - type: The type of the created image source
	@inlinable convenience init?(images: [CGImage], type: DSFImageSourceType = .tiff) {
		self.init(images: images, utiType: type.rawValue)
	}
	
	/// Make an image source using the contents of the specified images
	/// - Parameters:
	///   - images: The images to include in the source
	///   - type: The type of the created image source
	convenience init?(images: [CGImage], utiType: String) {
		guard
			let mutableData = CFDataCreateMutable(nil, 0),
			let destination = CGImageDestinationCreateWithData(mutableData, utiType as CFString, images.count, nil)
		else {
			return nil
		}
		
		// Add all of the images.
		images.forEach { image in
			CGImageDestinationAddImage(destination, image, nil)
		}
		
		guard CGImageDestinationFinalize(destination) else {
			return nil
		}
		
		self.init(data: mutableData as Data)
	}
}

// MARK: - Generating image data

public extension DSFImageSource {
	/// Returns the image data
	/// - Parameters:
	///   - exportType: The type of image data to export
	///   - removeGPSData: If true, removes GPS data from the image before saving
	/// - Returns: The image data
	@inlinable func data(imageType: DSFImageSourceType? = nil, removeGPSData: Bool = false) -> Data? {
		return self.data(utiType: imageType?.rawValue, removeGPSData: removeGPSData)
	}
	
	/// Returns the image data
	/// - Parameters:
	///   - utiType: The UTI for the image export (eg. "public.jpeg"). If not specified, uses the images built-in type
	///   - removeGPSData: If true, removes GPS data from the image before saving
	/// - Returns: The image data
	@objc func data(
		utiType: String? = nil,
		removeGPSData: Bool = false
	) -> Data? {
		let exportType = utiType ?? self.type
		guard
			let mutableData = CFDataCreateMutable(nil, 0),
			let type = exportType,
			let destination = CGImageDestinationCreateWithData(mutableData, type as CFString, count, nil)
		else {
			return nil
		}
		
		var props: [CFString: Any?] = [:]
		if removeGPSData {
			props[kCGImagePropertyGPSDictionary] = kCFNull
		}
		
		// Add all of the images.
		(0 ..< self.count).forEach { index in
			CGImageDestinationAddImageFromSource(destination, imageSource, index, props as CFDictionary)
		}
		
		guard CGImageDestinationFinalize(destination) else {
			return nil
		}
		
		return mutableData as Data
	}
}

// MARK: - Generating platform specific images

public extension DSFImageSource {
#if os(macOS)
	/// Returns the image data
	/// - Parameters:
	///   - utiType: The UTI for the image export (eg. "public.jpeg"). If not specified, uses the images built-in type
	///   - removeGPSData: If true, removes GPS data from the image before saving
	/// - Returns: The image data
	@objc func image(utiType: String? = nil, removeGPSData: Bool = false) -> NSImage? {
		guard let data = self.data(utiType: utiType, removeGPSData: removeGPSData) else {
			return nil
		}
		return NSImage(data: data)
	}
#else
	/// Returns the image data
	/// - Parameters:
	///   - utiType: The UTI for the image export (eg. "public.jpeg"). If not specified, uses the images built-in type
	///   - removeGPSData: If true, removes GPS data from the image before saving
	/// - Returns: The image data
	@objc func image(utiType: String? = nil, removeGPSData: Bool = false) -> UIImage? {
		guard let data = self.data(utiType: utiType, removeGPSData: removeGPSData) else {
			return nil
		}
		return UIImage(data: data)
	}
#endif
}

// MARK: - Iterator helpers

public extension DSFImageSource {
	/// Loop through all images in the image source
	@inlinable func forEach(_ body: (DSFImageSource.Image) throws -> Void) rethrows {
		try (0 ..< self.count).forEach { index in
			if let im = self[index] { try body(im) }
		}
	}
	
	/// Return the first image in the image source
	@inlinable var first: DSFImageSource.Image? {
		guard self.count > 0, let im = self[0] else {
			return nil
		}
		return im
	}
	
	/// Return all the images in the image source
	@inlinable var images: [DSFImageSource.Image] {
		var result: [DSFImageSource.Image] = []
		self.forEach { image in result.append(image) }
		return result
	}
	
	/// Returns all the cgImages within the source
	@inlinable var cgImages: [CGImage] {
		return self.images.compactMap { $0.image }
	}
}
