//
//  WCGColor+contrasting.swift
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

// MARK: - Contrasting text color

public extension WCGColor {
	/// Returns a contrasting text color for this color
	@objc @inlinable static func contrastingTextColor(for color: CGColor) -> CGColor {
		color.contrastingTextColor()
	}

	@objc @inlinable static func contrastRatio(between color1: CGColor, and color2: CGColor) -> Double {
		color1.contrastRatio(to: color2)
	}
}

extension CGColor {
	/// Returns a contrasting text color for this color
	public func contrastingTextColor() -> CGColor {
		let darkText  = WCGColor.black
		let lightText = WCGColor.white
		return self.contrastRatio(to: darkText) > self.contrastRatio(to: lightText) ? darkText : lightText
	}

	/// Return the contrast ratio between this color and the provided color
	public func contrastRatio(to color: CGColor) -> CGFloat {
		 //  Method of calculation: https://www.w3.org/TR/WCAG20-TECHS/G18.html#G18-tests
		 //  It is recommended to stick to the contrast > 4.5

		 let luminance1 = self.luminance()
		 let luminance2 = color.luminance()

		 let luminanceDarker  = min(luminance1, luminance2)
		 let luminanceLighter = max(luminance1, luminance2)

		 return (luminanceLighter + 0.05) / (luminanceDarker + 0.05)
	}

	/// Return the luminance for the color
	public func luminance() -> CGFloat {
		guard
			let color = self.converted(to: WCGDefaultHexColorSpace, intent: .defaultIntent, options: nil),
			let r = color.components?[0],
			let g = color.components?[1],
			let b = color.components?[2]
		else {
			return 1
		}

		let adjust = { (component: CGFloat) -> CGFloat in
			 (component < 0.03928) ? (component / 12.92) : pow((component + 0.055) / 1.055, 2.4)
		}
		return 0.2126 * adjust(r) + 0.7152 * adjust(g) + 0.0722 * adjust(b)
	}
}
