import Foundation
import Sentry

protocol DebugProfileSentryReporterProtocol: Sendable {
    func report(path: String, reasonTag: String, jsonInfo: String?)
}

final class DebugProfileSentryReporter: DebugProfileSentryReporterProtocol {
    func report(path: String, reasonTag: String, jsonInfo: String? = nil) {
        let event = Event(level: .info)
        event.message = SentryMessage(formatted: "MW_\(reasonTag)")
        event.tags = ["report": "mw_profile", "reason": reasonTag]
        event.fingerprint = ["mw-profile", reasonTag]

        SentrySDK.capture(event: event) { scope in
            if let jsonInfo, !jsonInfo.isEmpty {
                if let data = jsonInfo.data(using: .utf8),
                   let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    scope.setContext(value: dict, key: "info")
                } else {
                    scope.setExtra(value: jsonInfo, key: "info")
                }
            }
            if !path.isEmpty {
                let url = URL(fileURLWithPath: path)
                scope.addAttachment(Attachment(
                    path: path,
                    filename: url.lastPathComponent,
                    contentType: url.debugProfileContentType
                ))
            }
        }
    }
}

private extension URL {
    var debugProfileContentType: String {
        switch pathExtension.lowercased() {
        case "zip": return "application/zip"
        case "json": return "application/json"
        case "log", "txt": return "text/plain"
        default: return "application/octet-stream"
        }
    }
}
