//
//  WCGImage+export.swift
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

import Foundation
import SwiftImageReadWrite

// MARK: [Exporting]

public extension WCGImage {
	/// Generate a JPEG representation
	/// - Parameters:
	///   - scale: The scale to apply to the image (eg scale == 2 -> dpi == 144.0)
	///   - compression: The compression level to use
	///   - excludeGPSData: If true, removes any GPS data in the resulting data
	/// - Returns: The JPEG data
	@inlinable func jpegData(scale: CGFloat = 1.0, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try image.representation.jpeg(scale: scale, compression: compression, excludeGPSData: excludeGPSData)
	}

	/// Generate a PNG representation
	/// - Parameters:
	///   - scale: The scale to apply to the image (eg scale == 2 -> dpi == 144.0)
	///   - compression: The compression level to use
	///   - excludeGPSData: If true, removes any GPS data in the resulting data
	/// - Returns: The PNG data
	@inlinable func pngData(scale: CGFloat = 1.0, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try image.representation.png(scale: scale, excludeGPSData: excludeGPSData)
	}

	/// Generate a TIFF representation
	/// - Parameters:
	///   - scale: The scale to apply to the image (eg scale == 2 -> dpi == 144.0)
	///   - compression: The compression level to use
	///   - excludeGPSData: If true, removes any GPS data in the resulting data
	/// - Returns: The TIFF data
	@inlinable func tiffData(scale: CGFloat = 1.0, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try image.representation.tiff(scale: scale, compression: compression, excludeGPSData: excludeGPSData)
	}

	/// Generate a HEIC representation
	/// - Parameters:
	///   - scale: The scale to apply to the image (eg scale == 2 -> dpi == 144.0)
	///   - compression: The compression level to use
	///   - excludeGPSData: If true, removes any GPS data in the resulting data
	/// - Returns: The HEIC data
	@inlinable func heicData(scale: CGFloat = 1.0, compression: CGFloat? = nil, excludeGPSData: Bool = false) throws -> Data {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try image.representation.heic(compression: compression, excludeGPSData: excludeGPSData)
	}
}
