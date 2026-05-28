import Foundation
import Services
import AnytypeCore
import Logger

protocol ThermalProfilerTriggerProtocol: AnyObject, Sendable {
    func startSubscription() async
    func stopSubscriptionAndClean() async
    func triggerManually(severity: DebugProfilerReason.ThermalSeverity) async
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
        guard FeatureFlags.pressureDebugReports else {
            Self.log.debug("[MW_PROFILE] Thermal subscription skipped: toggle OFF")
            return
        }
        guard CoreEnvironment.targetType.isDebug else {
            Self.log.debug("[MW_PROFILE] Thermal subscription skipped: not a debug-class build")
            return
        }
        // Apple requires reading `thermalState` before registering the observer,
        // otherwise `thermalStateDidChangeNotification` is never delivered.
        // https://developer.apple.com/documentation/foundation/processinfo/thermalstatedidchangenotification
        let initialState = ProcessInfo.processInfo.thermalState
        Self.log.debug("[MW_PROFILE] Thermal subscription started, initial state: \(String(describing: initialState))")
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

    func triggerManually(severity: DebugProfilerReason.ThermalSeverity) async {
        lastTrigger = nil
        await trigger(reason: .thermalState(severity))
    }

    private func handleThermalChange() async {
        let state = ProcessInfo.processInfo.thermalState
        Self.log.debug("[MW_PROFILE] Thermal state changed: \(String(describing: state))")
        switch state {
        case .fair:
            await trigger(reason: .thermalState(.fair))
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
            Self.log.debug("[MW_PROFILE] Thermal profiler skipped (cooldown): \(reason.tag)")
            return
        }
        lastTrigger = instant
        Self.log.debug("[MW_PROFILE] Thermal profiler triggered: \(reason.tag)")
        guard let path = await debugService.runProfiler(durationInSeconds: Self.profileDuration, reason: reason) else {
            Self.log.debug("[MW_PROFILE] Thermal runProfiler returned nil for reason: \(reason.tag)")
            return
        }
        Self.log.debug("[MW_PROFILE] Thermal runProfiler returned non-nil path for reason: \(reason.tag)")
        sentryReporter.report(path: path, reasonTag: reason.tag, jsonInfo: nil) { [debugService] in
            Task {
                Self.log.debug("[MW_PROFILE] Thermal report handed to Sentry, cleaning up source files")
                await debugService.cleanupReport(ts: Int(Date().timeIntervalSince1970))
            }
        }
    }
}
