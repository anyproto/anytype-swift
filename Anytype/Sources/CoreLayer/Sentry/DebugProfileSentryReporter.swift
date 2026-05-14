import Foundation
import Sentry

protocol DebugProfileSentryReporterProtocol: Sendable {
    func report(path: String, reasonTag: String, jsonInfo: String?, onCaptured: @Sendable () -> Void)
}

final class DebugProfileSentryReporter: DebugProfileSentryReporterProtocol {
    func report(path: String, reasonTag: String, jsonInfo: String?, onCaptured: @Sendable () -> Void) {
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
            // Use data-based attachment, not path-based: Sentry's transport reads
            // path attachments lazily on its own queue, but the caller deletes the
            // source file via `onCaptured`. Memory-map the read so we don't heap-copy
            // a multi-MB zip during the very memory/thermal pressure event that
            // produced it; the mapping stays valid even after the file is unlinked.
            if !path.isEmpty,
               let data = try? Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe) {
                let url = URL(fileURLWithPath: path)
                scope.addAttachment(Attachment(
                    data: data,
                    filename: url.lastPathComponent,
                    contentType: url.debugProfileContentType
                ))
            }
        }

        onCaptured()
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
