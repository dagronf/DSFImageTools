//
//  File.swift
//  
//
//  Created by Darren Ford on 1/12/2022.
//

import Foundation

class TestOutputContainer {
	let _root = FileManager.default.temporaryDirectory
	let _container: URL

	init(title: String) {
		_container = _root
			.appendingPathComponent(title)
			.appendingPathComponent(UUID().uuidString)
		try! FileManager.default.createDirectory(at: _container, withIntermediateDirectories: true)

		Swift.print("Temp files at: \(_container)")
	}

	func testFilenameWithName(_ name: String) throws -> URL {
		_container.appendingPathComponent(name)
	}
}

#if os(macOS)
public func getMacModel() -> String? {
	let service = IOServiceGetMatchingService(kIOMasterPortDefault,
															IOServiceMatching("IOPlatformExpertDevice"))
	var modelIdentifier: String?
	
	if let modelData = IORegistryEntryCreateCFProperty(service, "model" as CFString, kCFAllocatorDefault, 0).takeRetainedValue() as? Data {
		if let modelIdentifierCString = String(data: modelData, encoding: .utf8)?.cString(using: .utf8) {
			modelIdentifier = String(cString: modelIdentifierCString)
		}
	}
	
	IOObjectRelease(service)
	return modelIdentifier
}
#endif
