//
//  DSFImageSource+GPS.swift
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

import CoreLocation
import Foundation

public extension DSFImageSource {
	// MARK: GPS Information
	
	/// A location coordinate
	@objc class GPSCoordinate: NSObject {
		@objc public let value: Double
		@objc public let reference: String
		
		/// Returns the coordinates in "N" "E" orientation.
		@objc public var normalized: GPSCoordinate {
			var newValue = self.value
			var newRef = self.reference
			if self.reference == "S" { newValue = -newValue; newRef = "N" }
			if self.reference == "W" { newValue = -newValue; newRef = "E" }
			return GPSCoordinate(value: newValue, reference: newRef)
		}
		
		/// The degrees value for the coordinate
		@objc public private(set) lazy var degrees: Int = {
			let lat = abs(value)
			return Int(lat.rounded(.towardZero))
		}()
		
		/// The minutes value for the coordinate
		@objc public private(set) lazy var minutes: Int = {
			let midDec = value.truncatingRemainder(dividingBy: 1) * 60.0
			return Int(midDec.rounded(.towardZero))
		}()
		
		/// The seconds value for the coordinate
		@objc public private(set) lazy var seconds: Double = {
			let midDec = value.truncatingRemainder(dividingBy: 1) * 60.0
			return midDec.truncatingRemainder(dividingBy: 1) * 60.0
		}()
		
		@objc public init(value: Double, reference: String) {
			self.value = value
			self.reference = reference
		}
		
		@objc public init(value: Double, isLatitude: Bool) {
			self.value = value
			self.reference = isLatitude ? (value < 0 ? "S" : "N") : (value < 0 ? "W" : "E")
		}
		
		@objc public var dmsString: String {
			"\(self.degrees)° \(self.minutes)′ \(Self.fractionFormatter.string(from: NSNumber(value: self.seconds))!)\" \(self.reference)"
		}
		
		@objc public var stringValue: String {
			"\(Self.fractionFormatter.string(from: NSNumber(value: value))!) \(reference)"
		}
		
		override public var description: String { "\(self.value) \(self.reference)" }
		
		private static let fractionFormatter: NumberFormatter = {
			let f = NumberFormatter()
			f.maximumFractionDigits = 3
			return f
		}()
	}
	
	/// Location coordinates
	@objc class GPSCoordinates: NSObject {
		@objc public let latitude: GPSCoordinate
		@objc public let longitude: GPSCoordinate
		
		@objc public var normalized: GPSCoordinates {
			let lat = self.latitude.normalized
			let lon = self.longitude.normalized
			return GPSCoordinates(lat: lat.value, lon: lon.value)
		}
		
		@objc public var location: CLLocationCoordinate2D {
			let norm = self.normalized
			return CLLocationCoordinate2D(latitude: norm.latitude.value, longitude: norm.longitude.value)
		}
		
		@objc public init(lat: Double, latRef: String, lon: Double, lonRef: String) {
			self.latitude = GPSCoordinate(value: lat, reference: latRef)
			self.longitude = GPSCoordinate(value: lon, reference: lonRef)
		}
		
		@objc public init(lat: Double, lon: Double) {
			self.latitude = GPSCoordinate(value: lat, isLatitude: true)
			self.longitude = GPSCoordinate(value: lon, isLatitude: false)
		}
		
		override public var description: String {
			return "GPSCoordinate: \(self.latitude), \(self.longitude)"
		}
		
		static let fractionFormatter: NumberFormatter = {
			let f = NumberFormatter()
			f.maximumFractionDigits = 3
			return f
		}()
		
		@objc public var stringValue: String {
			"\(self.latitude.stringValue), \(self.longitude.stringValue)"
		}
		
		@objc public var dmsString: String {
			"\(self.latitude.dmsString), \(self.longitude.dmsString)"
		}
		
		/// Returns a degree/minute/second string representation
		@objc public var latitudeDMS: String {
			self.latitude.dmsString
		}
		
		/// Returns a degree/minute/second string representation
		@objc public var longitudeDMS: String {
			self.longitude.dmsString
		}
	}
}
