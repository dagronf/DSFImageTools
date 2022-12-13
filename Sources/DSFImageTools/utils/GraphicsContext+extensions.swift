//
//  GraphicsContext+extensions.swift
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
import CoreGraphics

// MARK: - CoreGraphics

extension CGContext {
	/// Execute the supplied block within a `saveGState() / restoreGState()` pair, providing a context
	/// to draw in during the execution of the block
	///
	/// - Parameter stateBlock: The block to execute within the new graphics state
	/// - Parameter context: The context to draw into within the block
	///
	/// Example usage:
	/// ```
	///    context.savingGState { ctx in
	///       ctx.addPath(unsetBackground)
	///       ctx.setFillColor(bgc1.cgColor)
	///       ctx.fillPath(using: .evenOdd)
	///    }
	/// ```
	@inlinable public func savingGState<ReturnType>(_ stateBlock: (_ context: CGContext) throws -> ReturnType) rethrows -> ReturnType {
		self.saveGState()
		defer { self.restoreGState() }
		return try stateBlock(self)
	}
}

// MARK: - AppKit

#if os(macOS)

import AppKit

extension NSGraphicsContext {
	/// A convenience method for saving and restoring the current graphics context.

	/// Execute the supplied block within a `NSGraphicsContext.saveGraphicsState()` / `NSGraphicsContext.restoreGraphicsState()`
	/// pair, providing a context to draw in during the execution of the block
	///
	/// - Parameter drawBlock: The block to execute within the new graphics state
	@objc @inlinable public static func savingGState(_ drawBlock: () -> Void) {
		NSGraphicsContext.saveGraphicsState()
		defer { NSGraphicsContext.restoreGraphicsState() }
		drawBlock()
	}
}

#endif
