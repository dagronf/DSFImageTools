//
//  DSFFileThumbnail.swift
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

#if !os(tvOS) && !os(watchOS)

import CoreGraphics
import Foundation
import QuickLook
import QuickLookThumbnailing

#if os(macOS)
import AppKit
#else
import UIKit
#endif

/// A simple thumbnail generator supporting older oses (eg. prior to 10.15)
@objc public class DSFFileThumbnail: NSObject {
	/// The file's thumbnail image
	@objc public private(set) var thumbnail: CGImage?

#if os(macOS)
	/// An NSImage representation of the thumbnail image
	@objc public var image: NSImage? {
		if let t = thumbnail { return NSImage(cgImage: t, size: .zero) }
		return nil
	}
#else
	/// A UIImage representation of the thumbnail image
	@objc public var image: UIImage? {
		if let t = thumbnail { return UIImage(cgImage: t) }
		return nil
	}
#endif

	/// Generate a thumbnail for a file
	/// - Parameters:
	///   - fileURL: The URL of the file to generate the thumbnail for
	///   - size: The dimensions of the generated image
	///   - scale: The scale of the thumbnail
	///   - icon: If true, generates the standard Finder icon instead of an image representation
	///   - completion: A completion handler for when the task completes
	@objc public static func Generate(
		for fileURL: URL,
		ofSize size: CGSize,
		scale: CGFloat = 1,
		icon: Bool = false,
		_ completion: @escaping (DSFFileThumbnail?) -> Void
	) {
		if #available(macOS 10.15, iOS 13, *) {
			Self.generateModern(for: fileURL, ofSize: size, scale: scale, icon: icon, completion)
		}
		else {
			Self.generateLegacy(for: fileURL, ofSize: size, scale: scale, icon: icon, completion)
		}
	}

	private init?(_ image: CGImage?) {
		if let i = image {
			self.thumbnail = i
		}
		else {
			return nil
		}
	}
}

extension DSFFileThumbnail {
	@available(macOS 10.15, iOS 13, *)
	private static func generateModern(
		for fileURL: URL,
		ofSize size: CGSize,
		scale: CGFloat = 1,
		icon: Bool = false,
		_ completion: @escaping (DSFFileThumbnail?) -> Void
	) {
		let generator = QLThumbnailGenerator.shared
		let request = QLThumbnailGenerator.Request(
			fileAt: fileURL,
			size: size,
			scale: scale,
			representationTypes: icon ? .icon : .thumbnail
		)
		generator.generateRepresentations(for: request) { thumbnail, type, error in
			completion(DSFFileThumbnail(thumbnail?.cgImage))
		}
	}

	private static func generateLegacy(
		for fileURL: URL,
		ofSize size: CGSize,
		scale: CGFloat = 1,
		icon: Bool = false,
		_ completion: @escaping (DSFFileThumbnail?) -> Void
	) {
#if os(macOS)
		let opts: [AnyHashable: Any?] = [
			kQLThumbnailOptionIconModeKey: icon,
			kQLThumbnailOptionScaleFactorKey: NSNumber(value: scale),
		]

		DispatchQueue.global(qos: .utility).async {
			let image = QLThumbnailImageCreate(kCFAllocatorDefault, fileURL as CFURL, size, opts as CFDictionary)
			completion(DSFFileThumbnail(image?.takeRetainedValue()))
		}

#else
		fatalError("We shouldn't get here")
#endif
	}
}

#endif
