//
//  DSFImageSource+Image.swift
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

private let ValidCompression: ClosedRange<CGFloat> = 0 ... 1.0

// MARK: - Individual image wrapper

/// The default DPI size
public let DefaultDPI = CGSize(width: 72.0, height: 72.0)

public extension DSFImageSource {
	/// An wrapper for an individual image within the image source
	@objc(DSFImageSourceImage) class Image: NSObject {
		@objc public let index: Int
		internal weak var source: DSFImageSource?

		@objc public init(_ source: DSFImageSource, index: Int) {
			self.source = source
			self.index = index
			super.init()
		}

		/// Returns the dimension of the image in pixels
		@objc @inlinable public var pixelSize: CGSize {
			if let i = self.image {
				return CGSize(width: i.width, height: i.height)
			}
			return DefaultDPI
		}

		// MARK: - Properties

		/// Returns the image properties as a dictionary.
		///
		/// See [ImageIO](https://developer.apple.com/documentation/imageio/cgimageproperties)
		@objc public var properties: [String: Any]? {
			guard let isource = source?.imageSource else { return nil }
			return CGImageSourceCopyPropertiesAtIndex(isource, self.index, nil) as? [String: Any]
		}

		/// Return the exif properties defined on the image
		@objc @inlinable public var exifProperties: [String: Any]? {
			return self.properties?[kCGImagePropertyExifDictionary as String] as? [String: Any]
		}

		/// Return the exif properties defined on the image
		@objc @inlinable public var tiffProperties: [String: Any]? {
			return self.properties?[kCGImagePropertyTIFFDictionary as String] as? [String: Any]
		}

		/// Return the exif properties defined on the image
		@available(macOS 10.15, *)
		@objc @inlinable public var heicProperties: [String: Any]? {
			return self.properties?[kCGImagePropertyHEICSDictionary as String] as? [String: Any]
		}


		// MARK: -  Image orientation

		/// Exif orientation
		///
		/// See: [EXIF orientation handling is a ghetto](https://web.archive.org/web/20210714165152/https://www.daveperrett.com/articles/2012/07/28/exif-orientation-handling-is-a-ghetto/)
		@objc @inlinable public var orientation: CGImagePropertyOrientation {
			// See https://www.daveperrett.com/articles/2012/07/28/exif-orientation-handling-is-a-ghetto/
			//
			if let i = self.properties?["Orientation"] as? UInt32 {
				return CGImagePropertyOrientation(rawValue: i) ?? CGImagePropertyOrientation.up
			}
			return CGImagePropertyOrientation.up
		}

		/// Return a CGImage representation that matches the input image but transformed to using the 'up' orientation
		@objc public func removingOrientation() -> CGImage? {
			guard let img = self.image else { return nil }

			// If the image orientation is .up, just return a copy of the input
			if self.orientation == .up { return img.copy() }

			return img.removingOrientation(orientation: self.orientation)
		}

		// MARK: - GPS information

		/// The gps properties associated with this image
		@objc public var gpsProperties: [String: Any]? {
			if let props = self.properties,
			   let gpsProps = props[kCGImagePropertyGPSDictionary as String] as? [String: Any]
			{
				// some Leica write GPS tags with a status tag of "V" (void) when no
				// GPS info is available.   If a status tag exists and its value
				// is "V" ignore the GPS data.
				if let status = gpsProps[kCGImagePropertyGPSStatus as String] as? String, status == "V" {
					return nil
				}
				return gpsProps
			}
			return nil
		}

		/// Does the image have location data
		@objc @inlinable public var hasLocation: Bool {
			return self.gpsProperties != nil
		}

		/// Get any location data associated with this image.
		@objc public var location: GPSCoordinates? {
			guard let gpsProps = self.gpsProperties else { return nil }
			if let lat = gpsProps[kCGImagePropertyGPSLatitude as String] as? Double,
			   let latRef = gpsProps[kCGImagePropertyGPSLatitudeRef as String] as? String,
			   let lon = gpsProps[kCGImagePropertyGPSLongitude as String] as? Double,
			   let lonRef = gpsProps[kCGImagePropertyGPSLongitudeRef as String] as? String
			{
				return GPSCoordinates(lat: lat, latRef: latRef, lon: lon, lonRef: lonRef)
			}
			return nil
		}

		// MARK: - GIF information

		/// Convenience for the gif properties for a subimage
		@objc @inlinable public var gifProperties: [String: Any]? {
			return self.properties?[kCGImagePropertyGIFDictionary as String] as? [String: Any]
		}

		@objc @inlinable public var gifDurationUnclamped: CFTimeInterval {
			if let val = self.gifProperties?[kCGImagePropertyGIFUnclampedDelayTime as String] as? NSNumber {
				return val.doubleValue as CFTimeInterval
			}
			return 0
		}

		@objc @inlinable public var gifDuration: CFTimeInterval {
			if let val = self.gifProperties?[kCGImagePropertyGIFDelayTime as String] as? NSNumber {
				return val.doubleValue as CFTimeInterval
			}
			return 0
		}

		// MARK: - DPI information

		/// Return the DPI for the image
		@objc @inlinable public var dpi: CGSize {
			if let w = self.properties?["DPIWidth"] as? CGFloat,
				let h = self.properties?["DPIHeight"] as? CGFloat {
				return CGSize(width: w, height: h)
			}
			return DefaultDPI
		}

		/// Returns a fractional dpi value (eg. 300dpi -> (300 / 72) == 4.166)
		@objc @inlinable public var dpiFraction: CGSize {
			return CGSize(
				width: self.dpi.width / DefaultDPI.width,
				height: self.dpi.height / DefaultDPI.height
			)
		}

		// MARK: - Generate image data

		/// Extract the data for the image
		/// - Parameters:
		///   - type: The
		///   - removeGPSData: If true, removes any GPS data that might exist in the image
		///   - compression: The compression level to apply. If the utiType doesn't support compression it is ignored
		///   - options: Other options as defined in [documentation](https://developer.apple.com/documentation/imageio/cgimagedestination/destination_properties)
		/// - Returns: The data for the image
		@inlinable public func imageData(
			type: DSFImageSourceType,
			removeGPSData: Bool = false,
			compression: CGFloat = .infinity,
			options: [String: Any]? = nil
		) -> Data? {
			return self.imageData(
				utiType: type.rawValue,
				removeGPSData: removeGPSData,
				compression: compression,
				options: options
			)
		}

		/// Extract the data for the image
		/// - Parameters:
		///   - utiType: The
		///   - removeGPSData: If true, removes any GPS data that might exist in the image
		///   - compression: The compression level to apply. If the utiType doesn't support compression it is ignored
		///   - options: Other options as defined in [documentation](https://developer.apple.com/documentation/imageio/cgimagedestination/destination_properties)
		/// - Returns: The data for the image
		@objc public func imageData(
			utiType: String,
			removeGPSData: Bool = false,
			compression: CGFloat = .infinity,
			options: [String: Any]? = nil
		) -> Data? {
			return self.image?.imageData(
				utiType: utiType,
				removeGPSData: removeGPSData,
				compression: compression,
				options: options
			)
		}

		// MARK: -  Extracting images

		/// Returns a CGImage, or nil for an error
		@objc public private(set) lazy var image: CGImage? = {
			guard let isource = source?.imageSource else { return nil }
			return CGImageSourceCreateImageAtIndex(isource, index, nil)
		}()

		/// Return a CGImage removing any rotation that might have been on the image
		@objc public private(set) lazy var normalizedImage: CGImage? = {
			guard let isource = source?.imageSource else { return nil }
			return CGImageSourceCreateImageAtIndex(isource, index, nil)?
				.removingOrientation(orientation: self.orientation)
		}()

		#if os(macOS)
		/// Returns an NSImage, or nil for an error
		@objc public private(set) lazy var nsImage: NSImage? = {
			if let i = self.image {
				return NSImage(cgImage: i, size: .zero)
			}
			return nil
		}()
		#else
		/// Returns a UIImage, or nil for an error
		@objc public private(set) lazy var uiImage: UIImage? = {
			if let i = self.image {
				return UIImage(cgImage: i)
			}
			return nil
		}()
		#endif

		// MARK: - Generating thumbnails

		/// Generate a thumbnail image
		/// - Parameters:
		///   - maxThumbnailSize: The maximum size of the thumbnail
		///   - otherOptions: Other options as defined in [documentation](https://developer.apple.com/documentation/imageio/cgimagesource/image_source_option_dictionary_keys)
		/// - Returns: The generated thumbnail
		@objc public func thumbnail(
			maxThumbnailSize: Int = 300,
			otherOptions: [String: Any]? = nil
		) -> CGImage? {
			guard let isource = source?.imageSource else { return nil }
			var opts: [CFString: Any] = [
				kCGImageSourceThumbnailMaxPixelSize: maxThumbnailSize,
				kCGImageSourceCreateThumbnailFromImageIfAbsent: true,
			]

			// Add in the user's options
			otherOptions?.forEach { opts[$0.0 as CFString] = $0.1 }
			return CGImageSourceCreateThumbnailAtIndex(isource, self.index, opts as CFDictionary)
		}

		#if os(macOS)
		@inlinable @objc public func thumbnailImage(
			maxThumbnailSize: Int = 300,
			otherOptions: [String: Any]? = nil
		) -> NSImage? {
			if let t = self.thumbnail(maxThumbnailSize: maxThumbnailSize, otherOptions: otherOptions) {
				return NSImage(cgImage: t, size: .zero)
			}
			return nil
		}
		#else
		@inlinable @objc public func thumbnailImage(
			maxThumbnailSize: Int = 300,
			otherOptions: [String: Any]? = nil
		) -> UIImage? {
			if let t = self.thumbnail(maxThumbnailSize: maxThumbnailSize, otherOptions: otherOptions) {
				return UIImage(cgImage: t)
			}
			return nil
		}
		#endif
	}
}
