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

    private var observer: NotificationCancellable?
    private var lastTrigger: ContinuousClock.Instant?

    init() {}

    func startSubscription() async {
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
        await debugService.runProfiler(durationInSeconds: Self.profileDuration, reason: reason)
    }
}
