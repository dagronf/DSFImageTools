//
//  DSFImageSource+Convert.swift
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

#if os(macOS)

import AppKit
import CoreGraphics
import Foundation

internal extension DSFImageSource {
	static func extractImages(_ image: NSImage) -> [CGImage] {
		var result = [CGImage]()
		image.representations
			.compactMap { $0 as? NSBitmapImageRep }
			.forEach { bitmapRep in
				if let frameCount = bitmapRep.value(forProperty: NSBitmapImageRep.PropertyKey.frameCount) as? Int {
					for count in 0 ..< frameCount {
						bitmapRep.setProperty(NSBitmapImageRep.PropertyKey.currentFrame, withValue: count as Any)
						Swift.print(bitmapRep)
						
						if let b = bitmapRep.cgImage {
							result.append(b)
						}
					}
				}
				else if let cgi = bitmapRep.cgImage {
					result.append(cgi)
				}
			}
		return result
	}
	
	static func Convert(_ image: NSImage) -> CGImageSource? {
		let images = self.extractImages(image)
		if images.count == 0 { return nil }
		let types = Set(images.compactMap { $0.utType })
		let outputType = types.count == 1 ? (types.first ?? kUTTypeTIFF) : kUTTypeTIFF
		
		guard
			let mutableData = CFDataCreateMutable(nil, 0),
			let destination = CGImageDestinationCreateWithData(mutableData, outputType, images.count, nil)
		else {
			return nil
		}
		
		images.forEach { CGImageDestinationAddImage(destination, $0, nil) }
		
		guard CGImageDestinationFinalize(destination) else {
			return nil
		}
		
		return CGImageSourceCreateWithData(mutableData, nil)
	}
}

#endif
