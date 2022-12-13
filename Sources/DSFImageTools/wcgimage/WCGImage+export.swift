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

// MARK: [Exporting]

public extension WCGImage {
	/// Generate a JPEG representation
	/// - Parameters:
	///   - compression: The compression level to use
	///   - excludeGPSData: If true, removes any GPS data in the resulting data
	/// - Returns: The JPEG data
	@inlinable func jpegData(compression: Double = .infinity, excludeGPSData: Bool = false) throws -> Data {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImageStatic.jpegData(image: image, compression: compression, excludeGPSData: excludeGPSData)
	}

	/// Generate a PNG representation
	/// - Parameters:
	///   - compression: The compression level to use
	///   - excludeGPSData: If true, removes any GPS data in the resulting data
	/// - Returns: The PNG data
	@inlinable func pngData(compression: Double = .infinity, excludeGPSData: Bool = false) throws -> Data {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImageStatic.pngData(image: image, compression: compression, excludeGPSData: excludeGPSData)
	}

	/// Generate a TIFF representation
	/// - Parameters:
	///   - compression: The compression level to use
	///   - excludeGPSData: If true, removes any GPS data in the resulting data
	/// - Returns: The TIFF data
	@inlinable func tiffData(compression: Double = .infinity, excludeGPSData: Bool = false) throws -> Data {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return try WCGImageStatic.tiffData(image: image, compression: compression, excludeGPSData: excludeGPSData)
	}
}
