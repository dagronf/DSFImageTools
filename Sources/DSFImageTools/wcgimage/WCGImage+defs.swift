//
//  DSFImageTools+Defs.swift
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

import Foundation

/// Errors thrown by this library
public enum DSFImageToolsErrorType: Error {
	case invalidImage
	case cannotCreateImage
	case unableToCopy
	case invalidContext
	case unableToCreateImageFromContext
	case invalidCompression
	case cannotCreateDestination
	case unableToMask
	case invalidColorspace
	case invalidParameters
	case invalidHexColor
}

/// The type of scaling to apply to an image
@objc public enum WCGImageScalingType: Int {
	/// Scale the X and Y axes independently when resizing the image
	case axesIndependent = 0
	/// Scale the X and Y axes equally so that the entire image fills the specified size
	case aspectFill = 1
	/// Sclae the X and Y axes equally so that the entire image fits within the specified size
	case aspectFit = 2
}

/// The type of flipping to apply to an image
@objc public enum WCGImageFlipType: Int {
	/// Flip horizontally
	case horizontally = 0
	/// Flip vertically
	case vertically = 1
	/// Flip across both axes
	case both = 2
}
