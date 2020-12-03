import Darwin.C
import AppKit

func toJson<T>(_ data: T) throws -> String {
	let json = try JSONSerialization.data(withJSONObject: data)
	return String(data: json, encoding: .utf8)!
}

func printFrontmostApp() {
	let windows = CGWindowListCopyWindowInfo([.optionOnScreenOnly, .excludeDesktopElements], kCGNullWindowID) as! [[String: Any]]

	// window list is ordered - first app is the top one
	for window in windows {
		// Skip transparent windows, like with Chrome
		if (window[kCGWindowAlpha as String] as! Double) == 0 {
			continue
		}

		let bounds = CGRect(dictionaryRepresentation: window[kCGWindowBounds as String] as! CFDictionary)!

		// Skip tiny windows, like the Chrome link hover statusbar
		let minWinSize: CGFloat = 50
		if bounds.width < minWinSize || bounds.height < minWinSize {
			continue
		}

		let appPid = window[kCGWindowOwnerPID as String] as! pid_t

		let appWrapper = NSRunningApplication(processIdentifier: appPid)
		if appWrapper == nil {
			continue
		}

	  let app = appWrapper!
		let bundleId = app.bundleIdentifier!
		if bundleId == "com.apple.dock" || bundleId == "com.apple.notificationcenterui" ||
				bundleId == "com.apple.screencaptureui" {
			continue
		}

		let dict: [String: Any] = [
			"title": window[kCGWindowName as String] as? String ?? "",
			"id": window[kCGWindowNumber as String] as! Int,
			"bounds": [
				"x": bounds.origin.x,
				"y": bounds.origin.y,
				"width": bounds.width,
				"height": bounds.height
			],
			"owner": [
				"name": window[kCGWindowOwnerName as String] as! String,
				"processId": appPid,
				"bundleId": bundleId,
				"path": app.bundleURL!.path
			],
			"memoryUsage": window[kCGWindowMemoryUsage as String] as! Int
		]

		print(try! toJson(dict))
		fflush(stdout)
		return
	}
}

while(true) {
	printFrontmostApp()
	readLine()
}
