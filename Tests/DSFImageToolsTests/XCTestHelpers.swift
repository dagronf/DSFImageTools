//
//  XCTestHelpers.swift
//  Created by Darren Ford on 26/11/21.
//
//  MIT license
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
//  rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to
//  permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial
//  portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import XCTest

extension XCTestCase {
	/// Run test and catch anything that is thrown
	func performTest(closure: () throws -> Void) {
		do {
			try closure()
		}
		catch {
			XCTFail("Unexpected error thrown: \(error)")
		}
	}
}

/// Perform the current throwing expression, and (if successful) return the result of the expression (otherwise nil)
/// - Returns: The result of 'expression' if no throwing error occurs, otherwise nil
func XCTAssertNoThrowWithReturn<T>(
	_ expression: @autoclosure () throws -> T,
	_ message: @autoclosure () -> String = "",
	file: StaticString = (#filePath),
	line: UInt = #line
) -> T? {
	var r: T?
	XCTAssertNoThrow(
		try { r = try expression() }(), message(), file: file, line: line)
	return r
}

struct UnexpectedNilError: Error {}
/// Perform the expression, and unwrap the result. Throws `UnexpectedNilError` if the expression returns nil
func XCTAssertUnwrap<T>(_ variable: T?, message: String = "Unexpected nil variable", file: StaticString = #file, line: UInt = #line) throws -> T {
	guard let variable = variable else {
		XCTFail(message, file: file, line: line)
		throw UnexpectedNilError()
	}
	return variable
}


/// A temporary file class that removes the temporary file when it goes out of scope
class XCTTemporaryFile {
	let fileURL: URL
	init(prefix: String? = nil, fileExtension: String? = nil, contents: Data? = nil) throws {
		var tempFilename = ""

		// prefix
		if let prefix = prefix {
			tempFilename += prefix + "_"
		}

		// unique name
		tempFilename += ProcessInfo.processInfo.globallyUniqueString

		// extension
		if let fileExtension = fileExtension {
			tempFilename += "." + fileExtension
		}

		// create the temporary file url
		let tempURL = try FileManager.default.url(
			for: .itemReplacementDirectory,
				in: .userDomainMask,
				appropriateFor: URL(fileURLWithPath: NSTemporaryDirectory()),
				create: true
		)
			.appendingPathComponent(tempFilename)

		// if contents were specified, write the file with the contents
		if let contents = contents {
			try contents.write(to: tempURL, options: .atomicWrite)
		}

		self.fileURL = tempURL
	}

	deinit {
		try? FileManager.default.removeItem(at: fileURL)
	}
}
