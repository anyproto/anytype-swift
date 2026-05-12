import Foundation
import Sentry
import Services
import ProtobufMessages
import Combine
import Logger

protocol DebugProfileEventHandlerProtocol: AnyObject, Sendable {
    func startSubscription() async
    func stopSubscriptionAndClean() async
}

actor DebugProfileEventHandler: DebugProfileEventHandlerProtocol {

    // WORKAROUND: Force linker to retain Anytype_Event.Debug metadata.
    // Mirrors MembershipStatusStorage workaround — nested type metadata can be
    // stripped in Release builds when never referenced directly.
    private static let _forceParentTypeRetention: Anytype_Event.Debug.Type = Anytype_Event.Debug.self

    private static let log = EventLogger(category: "DebugProfileEventHandler")

    private var subscription: AnyCancellable?

    init() {}

    func startSubscription() async {
        subscription = EventBunchSubscribtion.default.addHandler { [weak self] events in
            await self?.handle(events: events)
        }
    }

    func stopSubscriptionAndClean() async {
        subscription = nil
    }

    private func handle(events: EventsBunch) {
        for event in events.middlewareEvents {
            if case .debugProfileCreated(let profile) = event.value {
                forwardToSentry(profile)
            }
        }
    }

    private func forwardToSentry(_ profile: Anytype_Event.Debug.ProfileCreated) {
        let reason = profile.reason.isEmpty ? "Unknown" : profile.reason
        Self.log.debug("DebugProfileCreated: reason=\(reason), path=\(profile.path), full=\(profile.full)")

        let event = Event(level: .info)
        event.message = SentryMessage(formatted: "MW_\(reason)")
        event.tags = ["report": "mw_profile", "reason": reason]
        event.fingerprint = ["mw-profile", reason]

        SentrySDK.capture(event: event) { scope in
            if let data = profile.jsonInfo.data(using: .utf8),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                scope.setContext(value: dict, key: "info")
            } else if !profile.jsonInfo.isEmpty {
                scope.setExtra(value: profile.jsonInfo, key: "info")
            }

            if !profile.path.isEmpty {
                let url = URL(fileURLWithPath: profile.path)
                scope.addAttachment(Attachment(
                    path: profile.path,
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
