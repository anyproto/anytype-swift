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
        guard CoreEnvironment.targetType.isDebug else {
            Self.log.debug("[MW_PROFILE] Memory pressure subscription skipped: not a debug-class build")
            return
        }
        Self.log.debug("[MW_PROFILE] Memory pressure subscription started")
        let source = DispatchSource.makeMemoryPressureSource(
            eventMask: [.normal, .warning, .critical],
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
        guard let data = source?.data else {
            Self.log.debug("[MW_PROFILE] Memory pressure event fired but source.data was nil")
            return
        }
        Self.log.debug("[MW_PROFILE] Memory pressure event fired: \(data.logName)")
        if data.contains(.critical) {
            await trigger(reason: .memoryPressure(.critical))
        } else if data.contains(.warning) {
            await trigger(reason: .memoryPressure(.warning))
        }
    }

    private func trigger(reason: DebugProfilerReason) async {
        let instant = ContinuousClock.now
        if let lastTrigger, lastTrigger.duration(to: instant) < Self.cooldown {
            Self.log.debug("[MW_PROFILE] Memory profiler skipped (cooldown): \(reason)")
            return
        }
        lastTrigger = instant
        Self.log.debug("[MW_PROFILE] Memory profiler triggered: \(reason)")
        guard let path = await debugService.runProfiler(durationInSeconds: 0, reason: reason) else {
            Self.log.debug("[MW_PROFILE] Memory runProfiler returned nil for reason: \(reason)")
            return
        }
        Self.log.debug("[MW_PROFILE] Memory runProfiler returned non-nil path for reason: \(reason)")
        sentryReporter.report(path: path, reasonTag: reason.tag, jsonInfo: nil) { [debugService] in
            Task {
                Self.log.debug("[MW_PROFILE] Memory report handed to Sentry, cleaning up source files")
                await debugService.cleanupReport(ts: Int(Date().timeIntervalSince1970))
            }
        }
    }
}

private extension DispatchSource.MemoryPressureEvent {
    var logName: String {
        if contains(.critical) { return "critical" }
        if contains(.warning) { return "warning" }
        if contains(.normal) { return "normal" }
        return "unknown(rawValue=\(rawValue))"
    }
}
