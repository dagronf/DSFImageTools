//
//  MarkdownGenerator.swift
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
import CoreGraphics
import DSFImageTools

class MarkdownGenerator {
	var content: String = ""

	var images: [(filename: String, imageData: Data)] = []

	func write(to destination: URL) throws {
		let file = FileWrapper(directoryWithFileWrappers: [:])
		let imageFolder = FileWrapper(directoryWithFileWrappers: [:])
		imageFolder.preferredFilename = "images"
		file.addFileWrapper(imageFolder)

		images.forEach { image in
			//let data = try WCGImage.pngData(image: image.1, compression: 0.7)
			let imageFile = FileWrapper(regularFileWithContents: image.imageData)
			imageFile.preferredFilename = image.filename
			imageFolder.addFileWrapper(imageFile)
		}

		let markdownFile = FileWrapper(regularFileWithContents: content.data(using: .utf8)!)
		markdownFile.preferredFilename = "index.md"
		file.addFileWrapper(markdownFile)

		try file.write(to: destination, originalContentsURL: nil)
	}

//	@discardableResult func h1(_ text: String) -> MarkdownGenerator {
//		content += "# \(text)\n\n"
//		return self
//	}

	@discardableResult func h1(_ text: String, _ block: ((MarkdownGenerator) throws -> Void)? = nil) rethrows -> MarkdownGenerator {
		content += "# \(text)\n\n"
		if let _ = block { try block?(self) }
		self.br()
		return self
	}

//	@discardableResult func h2(_ text: String) -> MarkdownGenerator {
//		content += "## \(text)\n\n"
//		return self
//	}

	@discardableResult func h2(_ text: String, _ block: ((MarkdownGenerator) throws -> Void)? = nil) rethrows -> MarkdownGenerator {
		content += "## \(text)\n\n"
		if let _ = block { try block?(self) }
		self.br()
		return self
	}

	@discardableResult func h3(_ text: String) -> MarkdownGenerator {
		content += "### \(text)\n\n"
		return self
	}

	@discardableResult func h4(_ text: String) -> MarkdownGenerator {
		content += "### \(text)\n\n"
		return self
	}

	@discardableResult func text(_ text: String) -> MarkdownGenerator {
		content += "\(text)\n"
		return self
	}

	@discardableResult func raw(_ text: String) -> MarkdownGenerator {
		content += text
		return self
	}

	@discardableResult func br() -> MarkdownGenerator {
		content += "\n\n"
		return self
	}

	@discardableResult func imageData(_ data: Data, extn: String, width: CGFloat? = nil, height: CGFloat? = nil, linked: Bool = true) throws -> MarkdownGenerator {
		let identifier = "\(UUID().uuidString).\(extn)"
		images.append((identifier, data))

		if linked {
			content += "<a href=\"./images/\(identifier)\">"
		}

		do {
			content += "<img src=\"./images/\(identifier)\"" // width=\"125\" />"
			if let width = width {
				content += " width=\"\(width)\""
			}
			if let height = height {
				content += " height=\"\(height)\""
			}
			content += " /> "
		}

		if linked {
			content += "</a>"
		}

		return self
	}


	@discardableResult func image(_ image: CGImage, width: CGFloat? = nil, height: CGFloat? = nil, linked: Bool = true) throws -> MarkdownGenerator {
		let identifier = "\(UUID().uuidString).png"

		let data = try WCGImage.pngData(image: image, compression: 0.7)
		images.append((identifier, data))

		if linked {
			content += "<a href=\"./images/\(identifier)\">"
		}

		do {
			content += "<img src=\"./images/\(identifier)\"" // width=\"125\" />"
			if let width = width {
				content += " width=\"\(width)\""
			}
			if let height = height {
				content += " height=\"\(height)\""
			}
			content += " /> "
		}

		if linked {
			content += "</a>"
		}

		return self
	}

}

import DSFImageTools
extension MarkdownGenerator {
	@discardableResult func image(
		_ image: WCGImage,
		width: CGFloat? = nil,
		height: CGFloat? = nil,
		linked: Bool = true
	) throws -> MarkdownGenerator {
		return try self.image(
			try image.cgImage(),
			width: width,
			height: height,
			linked: linked
		)
	}
}
