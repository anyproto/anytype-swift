import Foundation
import Logger
import SwiftEntryKit
import AnytypeCore

final class NonFatalLoggerHandler: AssertionLoggerHandler {
    
    func log(_ message: String, domain: String, info: [String: Any], tags: [String : String], file: String, function: String, line: UInt) {
        guard FeatureFlags.nonfatalAlerts else { return }
        let fileName = URL(string: file)?.deletingPathExtension().lastPathComponent ?? ""
        let title = "\(domain)\n\(fileName)\nfunction: \(function) (\(line))"
        let infoStrings = info.map { "\($0.key): \($0.value)" }
        let tagsStrings = tags.map { "\($0.key): \($0.value)" }
        let description = ([message] + infoStrings + tagsStrings).joined(separator: "\n")
        SwiftEntryKit.displayDebugError(title: title, description: description)
    }
}
