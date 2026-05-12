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

    private let now: @Sendable () -> ContinuousClock.Instant
    private var observer: NSObjectProtocol?
    private var lastTrigger: ContinuousClock.Instant?

    init(now: @escaping @Sendable () -> ContinuousClock.Instant = { ContinuousClock.now }) {
        self.now = now
    }

    func startSubscription() async {
        observer = NotificationCenter.default.addObserver(
            forName: ProcessInfo.thermalStateDidChangeNotification,
            object: nil,
            queue: nil
        ) { [weak self] _ in
            Task { await self?.handleThermalChange() }
        }
    }

    func stopSubscriptionAndClean() async {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        observer = nil
        lastTrigger = nil
    }

    func handleThermalChange() async {
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
        let instant = now()
        if let lastTrigger, lastTrigger.duration(to: instant) < Self.cooldown {
            Self.log.debug("Profiler skipped (cooldown): \(reason)")
            return
        }
        lastTrigger = instant
        Self.log.debug("Profiler triggered: \(reason)")
        await debugService.runProfiler(durationInSeconds: Self.profileDuration, reason: reason)
    }
}
