//
//  RTFDGenerator.swift
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

import Foundation
import AppKit

/// A basic rtfd file generator (macOS only)
class RTFDGenerator {
	var content = NSMutableAttributedString(string: "")

	/// Add a header1 with a line feed
	@discardableResult func h1(_ string: String) -> RTFDGenerator {
		let font = NSFont.boldSystemFont(ofSize: 28)
		let attributes = [NSAttributedString.Key.font: font]
		let attributedQuote = NSAttributedString(string: string + "\n", attributes: attributes)
		content.append(attributedQuote)
		return self
	}

	/// Add a header2 with a line feed
	@discardableResult func h2(_ string: String) -> RTFDGenerator {
		let font = NSFont.boldSystemFont(ofSize: 18)
		let attributes = [NSAttributedString.Key.font: font]
		let attributedQuote = NSAttributedString(string: string + "\n", attributes: attributes)
		content.append(attributedQuote)
		return self
	}

	/// Add raw text
	@discardableResult func text(_ string: String) -> RTFDGenerator {
		let font = NSFont.systemFont(ofSize: 14)
		let attributes = [NSAttributedString.Key.font: font]
		let attributedQuote = NSAttributedString(string: string, attributes: attributes)
		content.append(attributedQuote)
		return self
	}

	/// Add a line feed
	@discardableResult func br() -> RTFDGenerator {
		content.append(NSAttributedString(string: "\n"))
		return self
	}

	/// Add an image
	@discardableResult func image(_ image: NSImage) -> RTFDGenerator {
		let attachment = NSTextAttachment()
		attachment.image = image
		attachment.bounds = CGRect(origin: .zero, size: image.size)
		let attach = NSMutableAttributedString(attachment: attachment)
		content.append(attach)
		return self
	}

	/// Write the image to a RTFD bundle
	func write(_ fileURL: URL) throws {
		let fileWrapper = content.rtfdFileWrapper(
			from: NSRange(location: 0, length: content.length),
			documentAttributes: [.documentType: NSAttributedString.DocumentType.rtfd])!
		try fileWrapper.write(to: fileURL, options: [.atomic], originalContentsURL: nil)
	}
}

#if canImport(WCGImage)
import WCGImage
extension RTFDGenerator {
	@discardableResult func image(_ image: WCGImage) throws -> RTFDGenerator {
		self.image(try image.platformImage())
		return self
	}
}
#endif

#endif
