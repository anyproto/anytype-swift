import Foundation
import Services
import AnytypeCore
import Logger

protocol ThermalProfilerTriggerProtocol: AnyObject, Sendable {
    func startSubscription() async
    func stopSubscriptionAndClean() async
}

actor ThermalProfilerTrigger: ThermalProfilerTriggerProtocol {

    private static let log = EventLogger(category: "ThermalProfilerTrigger")

    private static let cooldown: Duration = .seconds(120)
    private static let profileDuration = 30

    @Injected(\.debugService)
    private var debugService: any DebugServiceProtocol
    @Injected(\.debugProfileSentryReporter)
    private var sentryReporter: any DebugProfileSentryReporterProtocol

    private var observer: NotificationCancellable?
    private var lastTrigger: ContinuousClock.Instant?

    init() {}

    func startSubscription() async {
        guard CoreEnvironment.targetType.isDebug else { return }
        let token = NotificationCenter.default.addObserver(
            forName: ProcessInfo.thermalStateDidChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            Task { await self?.handleThermalChange() }
        }
        observer = token.notificationCancellable()
    }

    func stopSubscriptionAndClean() async {
        observer = nil
        lastTrigger = nil
    }

    private func handleThermalChange() async {
        let state = ProcessInfo.processInfo.thermalState
        switch state {
        case .serious:
            await trigger(reason: .thermalState(.serious))
        case .critical:
            await trigger(reason: .thermalState(.critical))
        default:
            break
        }
    }

    private func trigger(reason: DebugProfilerReason) async {
        let instant = ContinuousClock.now
        if let lastTrigger, lastTrigger.duration(to: instant) < Self.cooldown {
            Self.log.debug("Profiler skipped (cooldown): \(reason)")
            return
        }
        lastTrigger = instant
        Self.log.debug("Profiler triggered: \(reason)")
        guard let path = await debugService.runProfiler(durationInSeconds: Self.profileDuration, reason: reason) else {
            return
        }
        sentryReporter.report(path: path, reasonTag: reason.tag, jsonInfo: nil)
    }
}
