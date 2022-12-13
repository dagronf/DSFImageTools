//
//  WCGImageStatic.swift
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

// Static image implementations

import CoreGraphics
import ImageIO
import Foundation

#if canImport(CoreImage)
import CoreImage
#endif

#if !os(macOS)
@usableFromInline internal let kUTTypeJPEG = "public.jpeg" as CFString
@usableFromInline internal let kUTTypePNG = "public.png" as CFString
@usableFromInline internal let kUTTypeTIFF = "public.tiff" as CFString
#endif

// MARK: [General]

@objc public class WCGImageStatic: NSObject {
	// Cannot create an instance of this class
	private override init() {}
}

public extension WCGImageStatic {
	/// The pixel size for the image
	@objc @inlinable @inline(__always) static func size(_ image: CGImage) -> CGSize {
		return CGSize(width: image.width, height: image.height)
	}

	/// The rect for the image
	@objc @inlinable @inline(__always) static func rect(_ image: CGImage) -> CGRect {
		return CGRect(origin: .zero, size: Self.size(image))
	}
}

// MARK: [Creation]

public extension WCGImageStatic {
	/// Create a CGImage with an sRGB colorspace
	/// - Parameters:
	///   - size: The size of the resulting image
	///   - backgroundColor: The color to fill the created image, or nil for no fill
	///   - drawBlock: A block used to draw content into the new image, or nil for no drawing
	/// - Returns: The created CGImage
	@objc static func Create(
		size: CGSize,
		backgroundColor: CGColor? = nil,
		_ drawBlock: ((CGContext, CGSize) -> Void)? = nil
	) throws -> CGImage {
		// Make the context. For the moment, always work in RGBA (CGColorSpace.sRGB)
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		guard
			let space = CGColorSpace(name: CGColorSpace.sRGB),
			let ctx = CGContext(
				data: nil,
				width: Int(size.width),
				height: Int(size.height),
				bitsPerComponent: 8,
				bytesPerRow: 0,
				space: space,
				bitmapInfo: bitmapInfo.rawValue
			)
		else {
			throw DSFImageToolsErrorType.invalidContext
		}

		// Drawing defaults
		ctx.setShouldAntialias(true)
		ctx.setAllowsAntialiasing(true)
		ctx.interpolationQuality = .high

		// If a background color is set, fill it here
		if let backgroundColor = backgroundColor {
			ctx.saveGState()
			ctx.setFillColor(backgroundColor)
			ctx.fill([CGRect(origin: .zero, size: size)])
			ctx.restoreGState()
		}

		// Perform the draw block
		if let block = drawBlock {
			ctx.saveGState()
			block(ctx, size)
			ctx.restoreGState()
		}

		guard let result = ctx.makeImage() else {
			throw DSFImageToolsErrorType.unableToCreateImageFromContext
		}
		return result
	}
}

// MARK: [Exporting]

internal extension WCGImageStatic {
	/// Returns a data representation of the image
	/// - Parameters:
	///   - image: The image
	///   - uttype: The UTType of the resulting data (eg. "public.png")
	///   - compression: The compression factor, or nil to use default
	///   - excludeGPSData: If true, removes any GPS data from the resulting image data
	/// - Returns: The data representation of the image, or nil if an error occurred.
	@usableFromInline static func imageData(
		image: CGImage,
		uttype: CFString,
		compression: Double? = nil,
		excludeGPSData: Bool = false
	) throws -> Data {
		if let mutableData = CFDataCreateMutable(nil, 0),
			let destination = CGImageDestinationCreateWithData(mutableData, uttype as CFString, 1, nil)
		{
			var options: [CFString: Any] = [:]
			if let compression = compression {
				guard (0.0 ... 1.0).contains(compression) else { throw DSFImageToolsErrorType.invalidCompression }
				options[kCGImageDestinationLossyCompressionQuality] = compression
			}
			if excludeGPSData == true {
				options[kCGImageMetadataShouldExcludeGPS] = true
			}
			CGImageDestinationAddImage(destination, image, options as CFDictionary)
			CGImageDestinationFinalize(destination)
			return mutableData as Data
		}

		throw DSFImageToolsErrorType.cannotCreateDestination
	}
}

public extension WCGImageStatic {
	/// Generate a JPEG representation for a CGImage
	/// - Parameters:
	///   - image: The image
	///   - compression: The compression level
	///   - excludeGPSData: If true, removes any GPS data in the resulting data
	/// - Returns: The JPEG data
	@objc @inlinable static func jpegData(
		image: CGImage,
		compression: Double = .infinity,
		excludeGPSData: Bool = false
	) throws -> Data {
		let compression = (compression == .infinity) ? nil : compression
		return try Self.imageData(image: image, uttype: kUTTypeJPEG, compression: compression, excludeGPSData: excludeGPSData)
	}

	/// Generate a PNG representation for a CGImage
	/// - Parameters:
	///   - image: The image
	///   - compression: The compression level
	///   - excludeGPSData: If true, removes any GPS data in the resulting data
	/// - Returns: The PNG data
	@objc @inlinable static func pngData(
		image: CGImage,
		compression: Double = .infinity,
		excludeGPSData: Bool = false
	) throws -> Data {
		let compression = (compression == .infinity) ? nil : compression
		return try Self.imageData(image: image, uttype: kUTTypePNG, compression: compression, excludeGPSData: excludeGPSData)
	}

	/// Generate a TIFF representation for a CGImage
	/// - Parameters:
	///   - image: The image
	///   - compression: The compression level
	///   - excludeGPSData: If true, removes any GPS data in the resulting data
	/// - Returns: The TIFF data
	@objc @inlinable static func tiffData(
		image: CGImage,
		compression: Double = .infinity,
		excludeGPSData: Bool = false
	) throws -> Data {
		let compression = (compression == .infinity) ? nil : compression
		return try Self.imageData(image: image, uttype: kUTTypeTIFF, compression: compression, excludeGPSData: excludeGPSData)
	}
}

// MARK: [Cropping]

public extension WCGImageStatic {
	/// Create an image by cropping an image to a rect
	/// - Parameters:
	///   - image: The image to crop
	///   - rect: The region of the image to crop out
	/// - Returns: The cropped image, or nil if an error occurs
	@objc @inlinable static func imageByCroppingImage(_ image: CGImage, to rect: CGRect) throws -> CGImage {
		guard let image = image.cropping(to: rect) else { throw DSFImageToolsErrorType.cannotCreateImage }
		return image
	}
}

// MARK: [Drawing]

public extension WCGImageStatic {
	/// Create a new image by applying a drawing a border around the outside of the image
	/// - Parameter drawBlock: The drawing block to perform
	/// - Returns: A new image
	@objc static func imageByDrawingBorderOnImage(
		_ image: CGImage,
		color: CGColor,
		lineWidth: CGFloat = 1
	) throws -> CGImage {
		let rect = WCGImageStatic.rect(image)
		return try WCGImageStatic.Create(size: rect.size) { ctx, size in

			// Draw the image into the new image
			ctx.savingGState { context in
				// draw the image into the new image
				context.draw(image, in: CGRect(origin: .zero, size: size))
			}

			// Call the drawing block
			ctx.savingGState { context in
				ctx.setStrokeColor(color)
				ctx.setLineWidth(lineWidth)
				ctx.stroke(rect.insetBy(dx: lineWidth / 2, dy: lineWidth / 2))
			}
		}
	}

	/// Create a new image by applying a drawing block on this image
	/// - Parameter drawBlock: The drawing block to perform
	/// - Returns: A new image
	@objc static func imageByDrawingOnImage(
		_ image: CGImage,
		_ drawBlock: @escaping (CGContext, CGSize) -> Void
	) throws -> CGImage {
		try WCGImageStatic.Create(size: WCGImageStatic.size(image)) { ctx, size in

			// Draw the image into the new image
			ctx.savingGState { context in
				// draw the image into the new image
				context.draw(image, in: CGRect(origin: .zero, size: size))
			}

			// Call the drawing block
			ctx.savingGState { context in
				drawBlock(context, size)
			}
		}
	}

	/// Create a new image by applying another image on top
	/// - Parameters:
	///   - image: The original image
	///   - applyingImage: The image to apply to the image
	///   - rect: The position within the image to draw the image
	///   - clippingPath: A path to clip the drawn image
	/// - Returns: A new image
	@objc static func imageByDrawingImageOnImage(
		_ image: CGImage,
		applyingImage apply: CGImage,
		in rect: CGRect = .zero,
		clippingPath: CGPath? = nil
	) throws -> CGImage {
		let size = WCGImageStatic.size(image)
		return try WCGImageStatic.Create(size: size) { ctx, size in
			// Draw the base image into the new context
			ctx.savingGState { context in
				// draw the image into the new image
				context.draw(image, in: CGRect(origin: .zero, size: size))
			}

			// Draw the image into the specified rect
			ctx.savingGState { context in
				// If there's a clipping path, clip the context to it
				if let c = clippingPath {
					// Clip to the mask path.
					context.addPath(c)
					context.clip()
				}

				// draw the applying image into the
				let r = (rect == .zero) ? CGRect(origin: .zero, size: size) : rect
				context.draw(apply, in: r)
			}
		}
	}

	/// Create a new image by applying transparency to an image
	/// - Parameters:
	///   - image: The original image
	///   - alpha: The alpha level for the new image (0 ... 1)
	/// - Returns: A new image
	@objc static func imageByApplyingAlpha(
		_ image: CGImage,
		alpha: CGFloat
	) throws -> CGImage {
		guard
			(0.0 ... 1.0).contains(alpha)
		else {
			Swift.print("Invalid alpha level \(alpha) - must be 0 -> 1")
			throw DSFImageToolsErrorType.invalidParameters
		}

		let size = WCGImageStatic.size(image)
		return try WCGImageStatic.Create(size: size) { ctx, size in
			ctx.setAlpha(alpha)
			ctx.draw(image, in: CGRect(origin: .zero, size: size))
		}
	}
}

// MARK: [Rotating]

public extension WCGImageStatic {
	/// Create a new image by flipping this image
	/// - Parameter flipType: The type of flipping to apply
	/// - Returns: A new image with the original image flipped
	@objc static func imageByFlippingImage(
		_ image: CGImage,
		flipType: WCGImageFlipType = .horizontally
	) throws -> CGImage {
		try WCGImageStatic.Create(size: WCGImageStatic.size(image)) { ctx, size in
			ctx.savingGState { context in
				// draw the image into the new image
				switch flipType {
				case .horizontally:
					context.scaleBy(x: 1, y: -1)
					context.translateBy(x: 0, y: -size.height)
				case .vertically:
					context.scaleBy(x: -1, y: 1)
					context.translateBy(x: -size.width, y: 0)
				case .both:
					context.scaleBy(x: -1, y: -1)
					context.translateBy(x: -size.width, y: -size.height)
				}
				context.draw(image, in: CGRect(origin: .zero, size: size))
			}
		}
	}
}

// MARK: [Flipping]

public extension WCGImageStatic {
	/// Create a new image by re-orienting the passed image
	/// - Parameters:
	///   - image: The image to reorient
	///   - orientation: The orientation to set for the new image
	/// - Returns: The re-oriented image, or nil if an error occurred
	@objc static func imageByRotatingImage(
		_ image: CGImage,
		to orientation: CGImagePropertyOrientation
	) throws -> CGImage {
		guard let colorSpace = image.colorSpace else {
			throw DSFImageToolsErrorType.invalidColorspace
		}

		let originalWidth = image.width
		let originalHeight = image.height
		let bitsPerComponent = image.bitsPerComponent
		let bitmapInfo = image.bitmapInfo

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
			degreesToRotate = -90.0
			swapWidthHeight = true
			mirrored = false
		case .rightMirrored:
			degreesToRotate = -90.0
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
			degreesToRotate = 90.0
			swapWidthHeight = true
			mirrored = false
		case .leftMirrored:
			degreesToRotate = 90.0
			swapWidthHeight = true
			mirrored = true
		}

		let radians = degreesToRotate * Double.pi / 180.0

		var width: Int
		var height: Int

		if swapWidthHeight {
			width = originalHeight
			height = originalWidth
		}
		else {
			width = originalWidth
			height = originalHeight
		}

		let bytesPerRow = (width * image.bitsPerPixel) / 8

		guard let ctx = CGContext(
			data: nil,
			width: width,
			height: height,
			bitsPerComponent: bitsPerComponent,
			bytesPerRow: bytesPerRow,
			space: colorSpace,
			bitmapInfo: bitmapInfo.rawValue
		)
		else {
			throw DSFImageToolsErrorType.invalidContext
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

		ctx.draw(image, in: CGRect(x: 0.0, y: 0.0, width: CGFloat(originalWidth), height: CGFloat(originalHeight)))

		guard let image = ctx.makeImage() else { throw DSFImageToolsErrorType.cannotCreateImage }
		return image
	}

	/// Create an image by rotating an image round its center
	/// - Parameters:
	///   - image: The image to rotate
	///   - radians: The rotation angle
	/// - Returns: The rotated image, or nil if an error occurred
	@objc static func imageByRotatingImage(_ image: CGImage, radians: CGFloat) throws -> CGImage {
		let origWidth = CGFloat(image.width)
		let origHeight = CGFloat(image.height)
		let origRect = CGRect(origin: .zero, size: CGSize(width: origWidth, height: origHeight))
		let rotatedRect = origRect.applying(CGAffineTransform(rotationAngle: radians))
		return try WCGImageStatic.Create(size: rotatedRect.size) { ctx, size in
			ctx.translateBy(x: rotatedRect.size.width * 0.5, y: rotatedRect.size.height * 0.5)
			ctx.rotate(by: -radians)
			ctx.draw(
				image,
				in: CGRect(
					x: -origWidth * 0.5,
					y: -origHeight * 0.5,
					width: origWidth,
					height: origHeight
				)
			)
		}
	}
}

// MARK: [Scaling]

public extension WCGImageStatic {
	/// Create an image by scaling the provided image to fit a target size
	/// - Parameters:
	///   - image: The image to scale
	///   - scalingType: The type of scaling to perform
	///   - targetSize: The target size for the image
	/// - Returns: The scaled image, or nil if an error occurred
	@objc static func imageByScalingImage(
		_ image: CGImage,
		scalingType: WCGImageScalingType = .axesIndependent,
		to targetSize: CGSize
	) throws -> CGImage {
		switch scalingType {
		case .axesIndependent:
			return try WCGImageStatic.imageByScalingImage(image, targetSize: targetSize)
		case .aspectFill:
			return try WCGImageStatic.imageByScalingImageToFill(image, targetSize: targetSize)
		case .aspectFit:
			return try WCGImageStatic.imageByScalingImageToFit(image, targetSize: targetSize)
		}
	}

	/// Create an image by scaling the provided image to fit a target size
	/// - Parameters:
	///   - image: The image to scale
	///   - targetSize: The target size for the image
	/// - Returns: The scaled image, or nil if an error occurred
	@objc @inlinable static func imageByScalingImage(_ image: CGImage, targetSize: CGSize) throws -> CGImage {
		try WCGImageStatic.Create(size: targetSize) { ctx, size in
			ctx.draw(image, in: CGRect(origin: .zero, size: targetSize))
		}
	}

	/// Create an image by scaling the provided image to fit the target size
	/// - Parameters:
	///   - image: The image to scale
	///   - targetSize: The target size for the image
	/// - Returns: The scaled image, or nil if an error occurred
	@objc static func imageByScalingImageToFit(_ image: CGImage, targetSize: CGSize) throws -> CGImage {
		let origSize = WCGImageStatic.size(image)
		// Keep aspect ratio
		var destWidth: CGFloat = 0
		var destHeight: CGFloat = 0
		let widthFloat = origSize.width
		let heightFloat = origSize.height
		if origSize.width > origSize.height {
			destWidth = targetSize.width
			destHeight = heightFloat * targetSize.width / widthFloat
		}
		else {
			destHeight = targetSize.height
			destWidth = widthFloat * targetSize.height / heightFloat
		}

		if destWidth > targetSize.width {
			destWidth = targetSize.width
			destHeight = heightFloat * targetSize.width / widthFloat
		}

		if destHeight > targetSize.height {
			destHeight = targetSize.height
			destWidth = widthFloat * targetSize.height / heightFloat
		}

		return try Self.Create(size: targetSize) { ctx, targetSize in
			ctx.draw(
				image,
				in: CGRect(
					x: (targetSize.width - destWidth) / 2,
					y: (targetSize.height - destHeight) / 2,
					width: destWidth,
					height: destHeight
				)
			)
		}
	}

	/// Create an image by scaling the provided image to fill the target size
	/// - Parameters:
	///   - image: The image to scale
	///   - targetSize: The target size for the image
	/// - Returns: The scaled image, or nil if an error occurred
	static func imageByScalingImageToFill(_ image: CGImage, targetSize: CGSize) throws -> CGImage {
		let origSize = WCGImageStatic.size(image)

		var destWidth: CGFloat = 0
		var destHeight: CGFloat = 0
		let widthRatio = targetSize.width / origSize.width
		let heightRatio = targetSize.height / origSize.height

		// Keep aspect ratio
		if heightRatio > widthRatio {
			destHeight = targetSize.height
			destWidth = origSize.width * targetSize.height / origSize.height
		}
		else {
			destWidth = targetSize.width
			destHeight = origSize.height * targetSize.width / origSize.width
		}

		return try Self.Create(size: targetSize) { ctx, targetSize in
			ctx.draw(
				image,
				in: CGRect(
					x: (targetSize.width - destWidth) / 2,
					y: (targetSize.height - destHeight) / 2,
					width: destWidth,
					height: destHeight
				)
			)
		}
	}
}

// MARK: [Coloring]

public extension WCGImageStatic {
	/// Returns a new image tinted with a color
	/// - Parameters:
	///   - image: The image to tint
	///   - color: The tint color
	///   - keepingAlpha: If true, transparency is maintained
	/// - Returns: A new image tinted with the specified color
	@objc static func imageByTintingImage(
		_ image: CGImage,
		with color: CGColor,
		keepingAlpha: Bool = true
	) throws -> CGImage {
		let rect = Self.rect(image)
		return try Self.Create(size: rect.size) { ctx, size in

			// draw black background to preserve color of transparent pixels
			ctx.setBlendMode(.normal)
			ctx.setFillColor(WCGColor.black)
			ctx.fill([rect])

			// Draw the image
			ctx.setBlendMode(.normal)
			ctx.draw(image, in: rect)

			// tint image (losing alpha) - the luminosity of the original image is preserved
			ctx.setBlendMode(.color)
			ctx.setFillColor(color)
			ctx.fill([rect])

			if keepingAlpha {
				// mask by alpha values of original image
				ctx.setBlendMode(.destinationIn)
				ctx.draw(image, in: rect)
			}
		}
	}

	/// Returns a grayscale version of the image
	/// - Parameters:
	///   - image: The image to tint
	///   - keepingAlpha: If true, transparency is maintained
	/// - Returns: A new grayscale image
	@inlinable @objc static func imageWithGrayscale(
		_ image: CGImage,
		keepingAlpha: Bool = true
	) throws -> CGImage {
		guard let ctx = CGContext(
			data: nil,
			width: image.width,
			height: image.height,
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: CGColorSpaceCreateDeviceGray(),
			bitmapInfo: keepingAlpha ? CGImageAlphaInfo.premultipliedLast.rawValue : CGImageAlphaInfo.none.rawValue
		)
		else {
			throw DSFImageToolsErrorType.invalidContext
		}

		/// Draw the image into the new context
		let imageRect = CGRect(origin: .zero, size: CGSize(width: image.width, height: image.height))

		/// Draw the image
		ctx.draw(image, in: imageRect)

		if keepingAlpha {
			ctx.setBlendMode(.destinationIn)
			ctx.clip(to: imageRect, mask: image)
		}

		guard let image = ctx.makeImage() else {
			throw DSFImageToolsErrorType.cannotCreateImage
		}
		return image
	}
}

// MARK: [Masking and clipping]

public extension WCGImageStatic {
	/// Create an image by clipping an image against a path
	/// - Parameters:
	///   - image: The image to clip
	///   - clippingPath: The clipping path
	/// - Returns: The clipped image
	@objc static func imageByClippingToPath(_ image: CGImage, clippingPath: CGPath) throws -> CGImage {
		let size = WCGImageStatic.size(image)
		return try WCGImageStatic.Create(size: size) { ctx, size in
			// Draw the image into the specified rect
			ctx.savingGState { context in
				context.addPath(clippingPath)
				context.clip()

				// draw the image into the context
				context.draw(image, in: CGRect(origin: .zero, size: size))
			}
		}
	}

	/// Returns an image by masking the input image with a mask image
	/// - Parameters:
	///   - image: The input image
	///   - maskImage: The mask image
	/// - Returns: A new image
	@objc static func imageByMaskingWithImage(_ image: CGImage, maskImage: CGImage) throws -> CGImage {
		let origSize = WCGImageStatic.size(image)

		guard
			let mask = CGImage(
				maskWidth: maskImage.width,
				height: maskImage.height,
				bitsPerComponent: maskImage.bitsPerComponent,
				bitsPerPixel: maskImage.bitsPerPixel,
				bytesPerRow: maskImage.bytesPerRow,
				provider: maskImage.dataProvider!,
				decode: nil,
				shouldInterpolate: false
			)
		else {
			throw DSFImageToolsErrorType.unableToMask
		}

		let imageRefWithAlpha = try WCGImageStatic.Create(size: origSize) { ctx, size in
			// Draw the original image in the bitmap context
			let r = CGRect(x: 0, y: 0, width: origSize.width, height: origSize.height)
			ctx.clip(to: r, mask: maskImage)
			ctx.draw(image, in: r)
		}

		guard let result = imageRefWithAlpha.masking(mask) else {
			throw DSFImageToolsErrorType.unableToMask
		}
		return result
	}
}

public extension WCGImageStatic {
	/// Returns a new image with a CMYK colorspace
	/// - Parameter image: The image to convert
	/// - Returns: The converted image
	@objc static func imageByConvertingToCMYK(_ image: CGImage) throws -> CGImage {
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
		guard let ctx = CGContext(
			data: nil,
			width: image.width,
			height: image.height,
			bitsPerComponent: 8,
			bytesPerRow: 0,
			space: CGColorSpaceCreateDeviceCMYK(),
			bitmapInfo: bitmapInfo.rawValue
		)
		else {
			throw DSFImageToolsErrorType.invalidContext
		}

		ctx.draw(image, in: CGRect(origin: .zero, size: Self.size(image)))
		guard let cgImage = ctx.makeImage() else {
			throw DSFImageToolsErrorType.cannotCreateImage
		}
		return cgImage
	}

	/// Returns a new image with an RGBA colorspace
	/// - Parameter image: The image to convert
	/// - Returns: The converted image
	@objc static func imageByConvertingToRGBA(_ image: CGImage) throws -> CGImage {
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		guard
			let space = CGColorSpace(name: CGColorSpace.sRGB),
			let ctx = CGContext(
				data: nil,
				width: image.width,
				height: image.height,
				bitsPerComponent: 8,
				bytesPerRow: 0,
				space: space,
				bitmapInfo: bitmapInfo.rawValue
			)
		else {
			throw DSFImageToolsErrorType.invalidContext
		}

		ctx.draw(image, in: CGRect(origin: .zero, size: Self.size(image)))
		guard let cgImage = ctx.makeImage() else {
			throw DSFImageToolsErrorType.cannotCreateImage
		}
		return cgImage
	}
}

#if canImport(CoreImage)
public extension WCGImageStatic {
	/// Adjust the saturation/brightness/contrast values for the image
	/// - Parameters:
	///   - image: The input image
	///   - saturation: The saturation value (0.0 ... 2.0)
	///   - brightness: The brightness value (-1.0 ... 1.0)
	///   - contrast: The contrast value (0.25 ... 4.0)
	/// - Returns: An image with adjusted colors
	@objc static func imageByAdjustingColorsInImage(
		_ image: CGImage,
		saturation: CGFloat = 1,
		brightness: CGFloat = 0,
		contrast: CGFloat = 1
	) throws -> CGImage {
		guard
			(0.0 ... 2.0).contains(saturation),
			(-1.0 ... 1.0).contains(brightness),
			(0.25 ... 4.0).contains(contrast)
		else {
			throw DSFImageToolsErrorType.invalidParameters
		}

		guard let filter = CIFilter(
			name: "CIColorControls",
			parameters: [
				"inputImage": CIImage(cgImage: image),
				"inputSaturation": saturation,
				"inputBrightness": brightness,
				"inputContrast": contrast,
			]
		)
		else {
			throw DSFImageToolsErrorType.cannotCreateImage
		}

		guard
			let output = filter.outputImage,
			let ctx = Optional(CIContext(options: nil)),
			let cgImage = ctx.createCGImage(output, from: output.extent)
		else {
			throw DSFImageToolsErrorType.cannotCreateImage
		}
		return cgImage
	}
}
#endif
