import Foundation
import Services
import AnytypeCore
import Logger

protocol MemoryPressureProfilerTriggerProtocol: AnyObject, Sendable {
    func startSubscription() async
    func stopSubscriptionAndClean() async
}

actor MemoryPressureProfilerTrigger: MemoryPressureProfilerTriggerProtocol {

    private static let log = EventLogger(category: "MemoryPressureProfilerTrigger")

    private static let cooldown: Duration = .seconds(30)

    @Injected(\.debugService)
    private var debugService: any DebugServiceProtocol

    private var source: (any DispatchSourceMemoryPressure)?
    private var lastTrigger: ContinuousClock.Instant?

    init() {}

    func startSubscription() async {
        let source = DispatchSource.makeMemoryPressureSource(
            eventMask: [.warning, .critical],
            queue: .global(qos: .utility)
        )
        source.setEventHandler { [weak self] in
            Task { [weak self] in
                await self?.handleEventFire()
            }
        }
        source.resume()
        self.source = source
    }

    func stopSubscriptionAndClean() async {
        source?.cancel()
        source = nil
        lastTrigger = nil
    }

    private func handleEventFire() async {
        guard let data = source?.data else { return }
        if data.contains(.critical) {
            await trigger(reason: .memoryPressure(.critical))
        } else if data.contains(.warning) {
            await trigger(reason: .memoryPressure(.warning))
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
        await debugService.runProfiler(durationInSeconds: 0, reason: reason)
    }
}
