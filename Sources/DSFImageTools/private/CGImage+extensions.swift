//
//  CGImage+extensions.swift
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
import ImageIO
import Foundation

#if canImport(CoreImage)
import CoreImage
#endif

private let ___ValidCompressionRange: ClosedRange<CGFloat> = 0 ... 1

extension CGImage {
	/// The size of the CGImage
	var size: CGSize {
		return CGSize(width: self.width, height: self.height)
	}
}

extension CGImage {
	/// Extract the data for the image
	/// - Parameters:
	///   - type: The type of image to export
	///   - removeGPSData: If true, removes any GPS data that might exist in the image
	///   - compression: The compression level to apply. If the utiType doesn't support compression it is ignored
	///   - options: Other options as defined in [documentation](https://developer.apple.com/documentation/imageio/cgimagedestination/destination_properties)
	/// - Returns: The data for the image
	func imageData(
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
	///   - utiType: The uti for the image to export.
	///   - removeGPSData: If true, removes any GPS data that might exist in the image
	///   - compression: The compression level to apply. If the utiType doesn't support compression it is ignored
	///   - options: Other options as defined in [documentation](https://developer.apple.com/documentation/imageio/cgimagedestination/destination_properties)
	/// - Returns: The data for the image
	func imageData(
		utiType: String,
		removeGPSData: Bool = false,
		compression: CGFloat = .infinity,
		options: [String: Any]? = nil
	) -> Data? {
		// Check that if compression is provided that it is within a valid range
		if compression.isFinite, ___ValidCompressionRange.contains(compression) == false {
			return nil
		}
		guard
			let mutableData = CFDataCreateMutable(nil, 0),
			let destination = CGImageDestinationCreateWithData(mutableData, utiType as CFString, 1, nil)
		else {
			return nil
		}
		
		var props: [CFString: Any?] = [:]
		if removeGPSData {
			props[kCGImagePropertyGPSDictionary] = kCFNull
		}
		if compression.isFinite {
			props[kCGImageDestinationLossyCompressionQuality] = NSNumber(value: compression) as CFNumber
		}
		
		// Add in the user's customizations
		options?.forEach { props[$0.0 as CFString] = $0.1 }
		
		CGImageDestinationAddImage(destination, self, props as CFDictionary)
		
		guard CGImageDestinationFinalize(destination) else {
			return nil
		}
		
		return mutableData as Data
	}
}

extension CGImage {
	// Returns a new image with its orientation as 'up'
	internal func removingOrientation(orientation: CGImagePropertyOrientation) -> CGImage? {
		let originalWidth = self.width
		let originalHeight = self.height
		let bitsPerComponent = self.bitsPerComponent
		//let bytesPerRow = self.bytesPerRow

		let colorSpace = self.colorSpace
		let bitmapInfo = self.bitmapInfo

		var degreesToRotate: Double
		var swapWidthHeight: Bool
		var mirrored: Bool
		switch orientation {
		case .up:
			degreesToRotate = 0.0
			swapWidthHeight = false
			mirrored = false
		case .upMirrored:
			degreesToRotate = 0.0
			swapWidthHeight = false
			mirrored = true
		case .right:
			degreesToRotate = 90.0
			swapWidthHeight = true
			mirrored = false
		case .rightMirrored:
			degreesToRotate = 90.0
			swapWidthHeight = true
			mirrored = true
		case .down:
			degreesToRotate = 180.0
			swapWidthHeight = false
			mirrored = false
		case .downMirrored:
			degreesToRotate = 180.0
			swapWidthHeight = false
			mirrored = true
		case .left:
			degreesToRotate = -90.0
			swapWidthHeight = true
			mirrored = false
		case .leftMirrored:
			degreesToRotate = -90.0
			swapWidthHeight = true
			mirrored = true
		}
		let radians = degreesToRotate * Double.pi / 180

		let width: Int
		let height: Int
		if swapWidthHeight {
			width = originalHeight
			height = originalWidth
		}
		else {
			width = originalWidth
			height = originalHeight
		}

		guard let ctx = CGContext(
			data: nil,
			width: width,
			height: height,
			bitsPerComponent: bitsPerComponent,
			bytesPerRow: 0,
			space: colorSpace!,
			bitmapInfo: bitmapInfo.rawValue)
		else {
			return nil
		}

		ctx.translateBy(x: CGFloat(width) / 2.0, y: CGFloat(height) / 2.0)
		if mirrored {
			ctx.scaleBy(x: -1.0, y: 1.0)
		}
		ctx.rotate(by: CGFloat(radians))
		if swapWidthHeight {
			ctx.translateBy(x: -CGFloat(height) / 2.0, y: -CGFloat(width) / 2.0)
		}
		else {
			ctx.translateBy(x: -CGFloat(width) / 2.0, y: -CGFloat(height) / 2.0)
		}
		ctx.draw(self, in: CGRect(x: 0, y: 0, width: originalWidth, height: originalHeight))

		return ctx.makeImage()
	}
}
