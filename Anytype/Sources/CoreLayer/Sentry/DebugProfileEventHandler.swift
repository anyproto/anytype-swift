import Foundation
import Services
import ProtobufMessages
import Combine
import Logger
import AnytypeCore

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

    @Injected(\.debugProfileSentryReporter)
    private var reporter: any DebugProfileSentryReporterProtocol
    @Injected(\.debugService)
    private var debugService: any DebugServiceProtocol

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
        reporter.report(path: profile.path, reasonTag: reason, jsonInfo: profile.jsonInfo) { [debugService] in
            Task {
                await debugService.cleanupReport(ts: Int(Date().timeIntervalSince1970))
            }
        }
    }
}
