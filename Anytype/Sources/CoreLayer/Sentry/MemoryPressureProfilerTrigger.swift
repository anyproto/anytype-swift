import Foundation
import Services
import AnytypeCore
import Logger

protocol MemoryPressureProfilerTriggerProtocol: AnyObject, Sendable {
    func startSubscription() async
    func stopSubscriptionAndClean() async
    func triggerManually(severity: DebugProfilerReason.MemorySeverity) async
}

actor MemoryPressureProfilerTrigger: MemoryPressureProfilerTriggerProtocol {

    private static let log = EventLogger(category: "MemoryPressureProfilerTrigger")

    private static let cooldown: Duration = .seconds(30)

    @Injected(\.debugService)
    private var debugService: any DebugServiceProtocol
    @Injected(\.debugProfileSentryReporter)
    private var sentryReporter: any DebugProfileSentryReporterProtocol

    private var source: (any DispatchSourceMemoryPressure)?
    private var lastTrigger: ContinuousClock.Instant?

    init() {}

    func startSubscription() async {
        guard CoreEnvironment.targetType.isDebug else { return }
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

    func triggerManually(severity: DebugProfilerReason.MemorySeverity) async {
        lastTrigger = nil
        await trigger(reason: .memoryPressure(severity))
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
        guard let path = await debugService.runProfiler(durationInSeconds: 0, reason: reason) else {
            return
        }
        sentryReporter.report(path: path, reasonTag: reason.tag, jsonInfo: nil)
        await debugService.cleanupReport(ts: Int(Date().timeIntervalSince1970))
    }
}
