//
//  WCGImage+platform.swift
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

#if os(macOS)
import AppKit
#else
import UIKit
#endif

// MARK: [Platform-specific exporting]

public extension WCGImage {
#if os(macOS)
	/// Create via NSImage
	/// - Parameter image: The image
	convenience init(_ image: NSImage) throws {
		guard let image = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { throw DSFImageToolsErrorType.invalidImage }
		try self.init(image: image)
	}

	/// Create an image from data
	/// - Parameter data: The data to create from
	convenience init(data: Data) throws {
		guard let image = NSImage(data: data) else { throw DSFImageToolsErrorType.invalidImage }
		try self.init(image)
	}
#else
	/// Create via UIImage
	/// - Parameter image: The image
	convenience init(_ image: UIImage) throws {
		guard let image = image.cgImage else { throw DSFImageToolsErrorType.invalidImage }
		try self.init(image: image)
	}

	/// Create an image from data
	/// - Parameter data: The data to create from
	convenience init(data: Data) throws {
		guard let image = UIImage(data: data) else { throw DSFImageToolsErrorType.invalidImage }
		try self.init(image)
	}
#endif
}

public extension WCGImage {
#if os(macOS)
	/// Return an NSImage representation of this image
	@inlinable func platformImage() throws -> NSImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return NSImage(cgImage: image, size: .zero)
	}
#else
	/// Return a UIImage representation of this image
	@inlinable func platformImage() throws -> UIImage {
		guard let image = self._owned else { throw DSFImageToolsErrorType.invalidImage }
		return UIImage(cgImage: image)
	}
#endif
}

// MARK: - SwiftUI conveniences

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 11, iOS 13, tvOS 13, watchOS 6, *)
public extension SwiftUI.Image {
	/// Create a SwiftUI Image with a WCGImage
	init(_ image: WCGImage, label: Text) {
		if let i = try? image.cgImage() {
			self.init(i, scale: 1, label: label)
		}
		else {
			self.init(systemName: "questionmark.app.dashed")
		}
	}
}

@available(macOS 11, iOS 13, tvOS 13, watchOS 6, *)
public extension WCGImage {
	/// Return an SwiftUI Image representation of this image
	@inlinable func ImageUI(label: Text) -> SwiftUI.Image {
		guard let image = self._owned else {
			return SwiftUI.Image(systemName: "questionmark.app.dashed")
		}
		return SwiftUI.Image(image, scale: 1, label: label)
	}
}

#endif

// MARK:    SwiftUI preview

#if DEBUG

#if canImport(SwiftUI)
import SwiftUI

@available(macOS 11, iOS 13, tvOS 13, watchOS 6, *)
struct DemoImageView: View {
	let base = try! WCGImage(
		size: CGSize(width: 100, height: 100),
		backgroundColor: CGColor(red: 1, green: 0, blue: 1, alpha: 1)) { ctx, sz in
			ctx.setFillColor(CGColor(srgbRed: 0, green: 0, blue: 1, alpha: 1))
			let p = CGPath(ellipseIn: CGRect(x: 10, y: 10, width: 50, height: 50), transform: nil)
			ctx.addPath(p)
			ctx.fillPath()

			ctx.setFillColor(CGColor(srgbRed: 0, green: 1, blue: 0, alpha: 1))
			let p2 = CGPath(ellipseIn: CGRect(x: 40, y: 40, width: 50, height: 50), transform: nil)
			ctx.addPath(p2)
			ctx.fillPath()
		}

	// This image will be released before display to make sure our fallback image works
	let rejected = try! WCGImage(dimension: 32)

	var body: some View {
		let _ = try! rejected.release()
		HStack {
			base.ImageUI(label: Text("Valid Image"))
			rejected.ImageUI(label: Text("Invalid Image"))
		}
	}
}

@available(macOS 11, iOS 13, tvOS 13, watchOS 6, *)
struct DemoImageView_Previews: PreviewProvider {
	static var previews: some View {
		DemoImageView()
			//.frame(width: 100)
	}
}

#endif

#endif
