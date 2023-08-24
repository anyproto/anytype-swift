import Foundation
import Logger
import SwiftEntryKit
import AnytypeCore

final class NonFatalLoggerHandler: AssertionLoggerHandler {
    
    func log(_ message: String, domain: String, info: [String: Any], file: String, function: String, line: UInt) {
        guard FeatureFlags.nonfatalAlerts else { return }
        
        let title = "\(domain)\nfunction: \(function) (\(line))"
        let infoStrings = info.map { "\($0.key): \($0.value)" }
        let description = ([message] + infoStrings).joined(separator: "\n")
        SwiftEntryKit.displayDebugError(title: title, description: description)
    }
}
