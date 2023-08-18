import Foundation
import Logger
import SwiftEntryKit
import AnytypeCore

final class NonFatalLoggerHandler: AssertionLoggerHandler {
    
    func log(_ message: String, domain: String, info: [String: Any]) {
        guard FeatureFlags.nonfatalAlerts else { return }
        
        let infoStrings = info.map { "\($0.key): \($0.value)" }
        let description = ([message] + infoStrings).joined(separator: "\n")
        SwiftEntryKit.displayDebugError(title: domain, description: description)
    }
}
