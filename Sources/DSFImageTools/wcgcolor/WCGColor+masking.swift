//
//  WCGColor+masking.swift
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

// Wrappers around creating pattern `CGColor`s

// https://www.kodeco.com/21462527-core-graphics-tutorial-patterns

import CoreGraphics
import Foundation

public class WCGColorPattern {
	/// The color pattern
	public var cgColor: CGColor = WCGColor.clear

	/// Create a pattern CGColor
	/// - Parameters:
	///   - bounds: The bounding box of the pattern cell, specified in pattern space. (Pattern space is an abstract space that maps to the default user space by the transformation matrix you specify with the matrix parameter.)The drawing done in your pattern drawing function is clipped to this rectangle.
	///   - xStep: The horizontal displacement between cells, specified in pattern space. For no additional horizontal space between cells (so that each pattern cells abuts the previous pattern cell in the horizontal direction), pass the width of the pattern cell.
	///   - yStep: The vertical displacement between cells, specified in pattern space. For no additional vertical space between cells(so that each pattern cells abuts the previous pattern cell in the vertical direction), pass the height of the pattern cell.
	///   - tiling: A CGPatternTiling constant that specifies the desired tiling method.
	///   - drawBlock: The pattern drawing block
	public init?(
		bounds: CGRect,
		xStep: CGFloat,
		yStep: CGFloat,
		tiling: CGPatternTiling = .constantSpacing,
		drawBlock: @escaping (CGContext) -> Void
	) {
		self.drawBlock = drawBlock

		let drawPattern: CGPatternDrawPatternCallback = { info, context in
			if let info = info {
				let owner = Unmanaged<WCGColorPattern>.fromOpaque(info).takeUnretainedValue()
				owner.drawBlock(context)
			}
		}

		var callbacks = CGPatternCallbacks(
			version: 0,
			drawPattern: drawPattern,
			releaseInfo: nil
		)

		// Store `self` in the info pointer, so we can access it in the pattern draw callback
		let ptr = Unmanaged.passUnretained(self).toOpaque()

		guard let pattern = CGPattern(
			info: ptr,
			bounds: bounds,
			matrix: .identity,
			xStep: xStep,
			yStep: yStep,
			tiling: tiling,
			isColored: true,
			callbacks: &callbacks
		)
		else {
			return nil
		}

		// For a color pattern the base colorspace should be nil.
		// This delegates the coloring to your pattern cell draw method
		let patternSpace = CGColorSpace(patternBaseSpace: nil)!

		var alpha: CGFloat = 1.0
		guard let patternColor = CGColor(patternSpace: patternSpace, pattern: pattern, components: &alpha) else {
			return nil
		}
		self.cgColor = patternColor
	}

	// Private
	private let drawBlock: (CGContext) -> Void
}

public class WCGMaskPattern {
	/// Create a masked CGColor pattern
	/// - Parameters:
	///   - bounds: The bounding box of the pattern cell, specified in pattern space. (Pattern space is an abstract space that maps to the default user space by the transformation matrix you specify with the matrix parameter.)The drawing done in your pattern drawing function is clipped to this rectangle.
	///   - xStep: The horizontal displacement between cells, specified in pattern space. For no additional horizontal space between cells (so that each pattern cells abuts the previous pattern cell in the horizontal direction), pass the width of the pattern cell.
	///   - yStep: The vertical displacement between cells, specified in pattern space. For no additional vertical space between cells(so that each pattern cells abuts the previous pattern cell in the vertical direction), pass the height of the pattern cell.
	///   - tiling: A CGPatternTiling constant that specifies the desired tiling method.
	///   - drawFunc: The pattern drawing block
	public init?(
		bounds: CGRect,
		xStep: CGFloat,
		yStep: CGFloat,
		tiling: CGPatternTiling = .constantSpacing,
		drawBlock: @escaping (CGContext) -> Void
	) {
		// Store the drawing function
		self.drawBlock = drawBlock

		// Define the pattern space's colorspace when drawing
		self.patternSpace = CGColorSpace(patternBaseSpace: CGColorSpaceCreateDeviceRGB())!

		// Configure the draw pattern callback to call back into this object
		let drawPattern: CGPatternDrawPatternCallback = { info, context in
			if let info = info {
				let owner = Unmanaged<WCGMaskPattern>.fromOpaque(info).takeUnretainedValue()
				owner.drawBlock(context)
			}
		}

		var callbacks = CGPatternCallbacks(
			version: 0,
			drawPattern: drawPattern,
			releaseInfo: nil
		)

		// Store `self` in the info pointer, so we can access it in the pattern draw callback
		let ptr = Unmanaged.passUnretained(self).toOpaque()

		guard let pattern = CGPattern(
			info: ptr,
			bounds: bounds,
			matrix: .identity,
			xStep: xStep,
			yStep: yStep,
			tiling: tiling,
			isColored: false,
			callbacks: &callbacks
		)
		else {
			return nil
		}
		self.pattern = pattern
	}

	/// Return a CGColor pattern with the specified masking color
	public func cgColor(maskColor: CGColor) -> CGColor? {
		guard
			let m = maskColor.converted(to: WCGDefaultHexColorSpace, intent: .defaultIntent, options: nil),
			let patternSpace = self.patternSpace,
			let pattern = self.pattern,
			var components = m.components,
			let patternColor = CGColor(
				patternSpace: patternSpace,
				pattern: pattern,
				components: &components
			)
		else {
			return nil
		}
		return patternColor
	}

	// Private
	private var patternSpace: CGColorSpace?
	private var pattern: CGPattern?
	private let drawBlock: (CGContext) -> Void
}
