//
//  WCGImage.swift
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
//

import CoreGraphics
import Foundation
import ImageIO

#if canImport(CoreImage)
import CoreImage
#endif

/// A cross-platform cgimage wrapper
public class WCGImage {

	// MARK: [Constructors]
	
	/// Create a new image from the contents of the specified file URL
	@inlinable public convenience init(fileURL: URL) throws {
		let data = try Data(contentsOf: fileURL)
		try self.init(data: data)
	}
	
	/// Create a new image by making a copy of the specified image
	@inlinable public init(image: WCGImage) throws {
		guard image.valid else { throw DSFImageToolsErrorType.invalidImage }
		guard let copy = image._owned?.copy() else { throw DSFImageToolsErrorType.unableToCopy }
		self._owned = copy
	}
	
	/// Create a new image taking ownership of the provided image
	@inlinable public init(image: CGImage?) throws {
		guard let image = image else { throw DSFImageToolsErrorType.invalidImage }
		self._owned = image
	}
	
	/// Create an image of a specified size and fill color
	/// - Parameters:
	///   - size: The size for the created image
	///   - backgroundColor: The color to fill the created image
	///   - drawBlock: A block of drawing commands to draw onto the image
	/// - Returns: The created image
	@inlinable public init(
		size: CGSize,
		backgroundColor: CGColor? = nil,
		_ drawBlock: ((CGContext, CGSize) -> Void)? = nil
	) throws {
		self._owned = try WCGImageStatic.Create(size: size, backgroundColor: backgroundColor, drawBlock)
	}
	
	/// Create an image of a specified size and fill color
	/// - Parameters:
	///   - dimension: The dimension for the created image
	///   - backgroundColor: The color to fill the created image
	///   - drawBlock:
	/// - Returns: The created image
	@inlinable public convenience init(
		dimension: Int,
		backgroundColor: CGColor? = nil,
		_ drawBlock: ((CGContext, CGSize) -> Void)? = nil
	) throws {
		try self.init(size: CGSize(width: dimension, height: dimension), backgroundColor: backgroundColor, drawBlock)
	}
	
	// MARK: [Private]
	
	// The underlying CGImage
	@usableFromInline internal var _owned: CGImage?
}

// MARK: [General]

public extension WCGImage {
	/// Is the underlying image still valid?
	@inlinable var valid: Bool { self._owned != nil }
	
	/// The pixel size for the image
	@inlinable func size() throws -> CGSize {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return WCGImageStatic.size(image)
	}
	
	/// Returns the underlying CGImage, marking this object as invalid
	@inlinable func release() throws -> CGImage {
		defer { self._owned = nil }
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return image
	}
	
	/// Return a copy of the underlying CGImage
	@inlinable func cgImage() throws -> CGImage {
		guard let copiedImage = self._owned?.copy() else { throw DSFImageToolsErrorType.invalidImage }
		return copiedImage
	}

	/// Return a copy of the underlying CGImage
	@inlinable func copy() throws -> WCGImage {
		try WCGImage(image: self)
	}

	/// Call the block passing in the underlying image. Try not to use this.
	@inlinable func unsafelyUnwrapped<ReturnType>(_ block: (CGImage) -> ReturnType) throws -> ReturnType {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return block(image)
	}
	
#if canImport(CoreImage)
	/// Returns a CIImage representation of the image
	@inlinable func ciImage() throws -> CIImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return CIImage(cgImage: image)
	}
#endif
	
	/// The colorspace for the underlying image, or nil if the image is invalid or not specified
	var colorSpace: CGColorSpace? { return self._owned?.colorSpace }
}

// MARK: [Operations]

public extension WCGImage {
	/// Returns a new image cropped to the specified rect
	/// - Parameter rect: The rectangle to crop this image
	/// - Returns: A new image, cropped to the specified rect
	@inlinable func cropping(to rect: CGRect) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: WCGImageStatic.imageByCroppingImage(image, to: rect))
	}
	
	/// Returns a new image rotated by the specified angle via the center
	/// - Parameter radians: The rotation angle
	/// - Returns: A new image
	@inlinable func rotating(by radians: CGFloat) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByRotatingImage(image, radians: radians))
	}
	
	/// Create a new image by re-orienting the passed image
	/// - Parameters:
	///   - image: The image to reorient
	///   - orientation: The orientation to set for the new image
	/// - Returns: The re-oriented image, or nil if an error occurred
	@inlinable func rotating(to orientation: CGImagePropertyOrientation) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByRotatingImage(image, to: orientation))
	}
	
	/// Returns a new image scaled to the specific size
	/// - Parameters:
	///   - scalingType: The type of scaling to employ
	///   - size: The resulting size for the image
	/// - Returns: The scaled image
	@inlinable func scaling(scalingType: WCGImageScalingType = .axesIndependent, to size: CGSize) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByScalingImage(image, scalingType: scalingType, to: size))
	}
	
	/// Returns a new image scaled to the specific size
	/// - Parameters:
	///   - scalingFactor: The scaling factor to apply
	/// - Returns: The scaled image
	@inlinable func scaling(by scalingFactor: CGFloat) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		var newRect = WCGImageStatic.rect(image)
		newRect.size.width *= scalingFactor
		newRect.size.height *= scalingFactor
		return try WCGImage(image: try WCGImageStatic.imageByScalingImageToFill(image, targetSize: newRect.size))
	}
	
	/// Returns a new flipped image
	/// - Parameter flipType: The type of flipping to perform
	/// - Returns: A new flipped image
	@inlinable func flipping(_ flipType: WCGImageFlipType) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByFlippingImage(image, flipType: flipType))
	}
	
	/// Returns a new image by performing the specified draw block on the current image
	/// - Parameter drawBlock: The drawing block
	/// - Returns: A new image
	@inlinable func drawing(_ drawBlock: @escaping (CGContext, CGSize) -> Void) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByDrawingOnImage(image, drawBlock))
	}
	
	/// Returns a new image by drawing a border around the outside of the image
	/// - Returns: A new image
	@inlinable func border(_ color: CGColor, lineWidth: CGFloat = 1) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByDrawingBorderOnImage(image, color: color, lineWidth: lineWidth))
	}
	
	/// Returns a new image by clipping this image to the specified path
	/// - Parameter path: The path to clip against
	/// - Returns: A new image
	@inlinable func clipping(to path: CGPath) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByClippingToPath(image, clippingPath: path))
	}

	/// Returns a new image by applying the result of the draw block into a clipping path
	/// - Parameters:
	///   - clipPath: The path within this image to clip to
	///   - drawBlock: The draw block which returns a WCGImage to clip onto this image
	/// - Returns: A new image
	@inlinable func applying(clipPath: CGPath, _ drawBlock: (WCGImage) throws -> WCGImage) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		do {
			let content = try drawBlock(WCGImage(size: try self.size()))
			let clippedContent = try WCGImageStatic.imageByClippingToPath(content.release(), clippingPath: clipPath)
			return try WCGImage(image: WCGImageStatic.imageByDrawingImageOnImage(image, applyingImage: clippedContent))
		}
		catch {
			throw error
		}
	}
	
	/// Return a tinted version of the image
	/// - Parameters:
	///   - color: The color to tint
	///   - keepingAlpha: If true, keeps transparency info
	/// - Returns: A tinted image
	@inlinable func tinting(with color: CGColor, keepingAlpha: Bool = false) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByTintingImage(image, with: color, keepingAlpha: keepingAlpha))
	}
	
	/// Return a grayscale version of the image
	/// - Parameters:
	///   - keepingAlpha: If true, keeps transparency info
	/// - Returns: A grayscale image with a gray colorspace
	@inlinable func grayscale(keepingAlpha: Bool = true) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageWithGrayscale(image, keepingAlpha: keepingAlpha))
	}

	/// Return a new image by applying transparency to this image
	/// - Parameter alpha: The alpha value to apply (0 ... 1)
	/// - Returns: A new image
	@inlinable func alpha(_ alpha: CGFloat) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(
			image: WCGImageStatic.imageByApplyingAlpha(image, alpha: alpha)
		)
	}

	/// Return a new image by drawing an image onto this image
	/// - Parameters:
	///   - appliedImage: The image to draw onto this image
	///   - rect: The rectangle in which to draw the image
	///   - clippingPath: The path to clip the applied image to
	/// - Returns: A new image
	@inlinable func applying(
		_ appliedImage: CGImage,
		in rect: CGRect = .zero,
		clippingPath: CGPath? = nil
	) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(
			image: try WCGImageStatic.imageByDrawingImageOnImage(
				image,
				applyingImage: appliedImage,
				in: rect,
				clippingPath: clippingPath
			)
		)
	}
	
	/// Returns a new image by masking. Transparent areas of the mask image are not drawn
	@inlinable func masking(to maskImage: CGImage) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByMaskingWithImage(image, maskImage: maskImage))
	}
	
	/// Returns a new image by masking. Transparent areas of the mask image are not drawn
	@inlinable func masking(to maskImage: WCGImage) throws -> WCGImage {
		guard let mask = maskImage._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try self.masking(to: mask)
	}
	
	/// Return a new image by drawing an image onto this image
	/// - Parameters:
	///   - appliedImage: The image to draw onto this image
	///   - rect: The rectangle in which to draw the image
	/// - Returns: A new image
	@inlinable func applying(_ appliedImage: WCGImage, in rect: CGRect = .zero) throws -> WCGImage {
		guard let appliedImage = appliedImage._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try self.applying(appliedImage, in: rect)
	}

	/// Return a new image by fill the path with the specified color on top of this image
	/// - Parameters:
	///   - color: The fill color
	///   - path: The path on this image to fill
	/// - Returns: A new image
	@inlinable func fill(_ color: CGColor, path: CGPath) throws -> WCGImage {
		return try self.drawing { ctx, size in
			ctx.setFillColor(color)
			ctx.addPath(path)
			ctx.fillPath()
		}
	}

	/// Return a new image by stroking the path with the specified color on top of this image
	/// - Parameters:
	///   - color: The stroke color
	///   - path: The path on this image to stroke
	/// - Returns: A new image
	@inlinable func stroke(_ color: CGColor, lineWidth: CGFloat = 1.0, path: CGPath) throws -> WCGImage {
		return try self.drawing { ctx, size in
			ctx.setStrokeColor(color)
			ctx.setLineWidth(lineWidth)
			ctx.addPath(path)
			ctx.fillPath()
		}
	}

	/// Return a new image by filling then stroking the specified path on top of this image
	/// - Parameters:
	///   - stroke: The stroke color
	///   - lineWidth: The width of the stroke
	///   - fill: The fill color
	///   - path: The path on this image to stroke
	/// - Returns: A new image
	func fillStroke(stroke: CGColor, lineWidth: CGFloat = 1, fill: CGColor, path: CGPath) throws -> WCGImage {
		return try self.drawing { ctx, size in
			ctx.setFillColor(fill)
			ctx.addPath(path)
			ctx.fillPath()

			ctx.setStrokeColor(stroke)
			ctx.setLineWidth(lineWidth)
			ctx.addPath(path)
			ctx.strokePath()
		}
	}

	/// Return a new image by filling then stroking the specified path on top of this image
	/// - Parameters:
	///   - stroke: The stroke color as a hex string
	///   - lineWidth: The width of the stroke
	///   - fill: The fill color as a hex string
	///   - path: The path on this image to stroke
	/// - Returns: A new image
	@inlinable func fillStroke(stroke: String, lineWidth: CGFloat = 1, fill: String, path: CGPath) throws -> WCGImage {
		guard
			let s = CGColor.fromHexString(stroke),
			let f = CGColor.fromHexString(fill)
		else {
			throw DSFImageToolsErrorType.invalidHexColor
		}
		return try fillStroke(stroke: s, lineWidth: 1, fill: f, path: path)
	}
}

#if canImport(CoreImage)
public extension WCGImage {
	/// Adjust the saturation/brightness/contrast values for the image
	/// - Parameters:
	///   - saturation: The saturation value (0.0 ... 2.0)
	///   - brightness: The brightness value (-1.0 ... 1.0)
	///   - contrast: The contrast value (0.25 ... 4.0)
	/// - Returns: An image with adjusted colors
	@inlinable func adjustingColors(
		saturation: CGFloat = 1,
		brightness: CGFloat = 0,
		contrast: CGFloat = 1
	) throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByAdjustingColorsInImage(
			image,
			saturation: saturation,
			brightness: brightness,
			contrast: contrast
		))
	}
}
#endif

// MARK: [ColorSpace]

public extension WCGImage {
	/// Convert the image to use a CMYK colorspace
	@inlinable func convertToCMYK() throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByConvertingToCMYK(image))
	}
	
	/// Convert the image to use an RGBA colorspace
	@inlinable func convertToRGBA() throws -> WCGImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImage(image: try WCGImageStatic.imageByConvertingToRGBA(image))
	}
}
