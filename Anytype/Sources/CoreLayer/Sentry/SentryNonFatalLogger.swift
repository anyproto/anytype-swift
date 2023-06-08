import Foundation
import Logger
import Sentry

final class SentryNonFatalLogger: AssertionLoggerHandler {
    
    func log(_ message: String, domain: String, info: [String: Any]) {
        
        let event = Event(level: .error)
        event.extra = info
        
        event.exceptions = [
            Exception(value: message, type: domain)
        ]
        
        SentrySDK.capture(event: event)
    }
}
