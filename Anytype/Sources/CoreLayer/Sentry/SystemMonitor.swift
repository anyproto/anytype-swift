import Foundation
import Services
import Factory
import Logger

private let log = EventLogger(category: "SystemMonitor")

@MainActor
final class SystemMonitor {

    @Injected(\.debugService)
    private var debugService: any DebugServiceProtocol

    private var memoryPressureSource: DispatchSourceMemoryPressure?
    private var lastTimedProfilerDate: Date?
    private var lastInstantProfilerDate: Date?

    private enum Constants {
        static let timedProfilerCooldown: TimeInterval = 5 * 60
        static let instantProfilerCooldown: TimeInterval = 30
    }

    nonisolated init() {}

    func start() {
        subscribeToThermalState()
        subscribeToMemoryPressure()
    }

    private func subscribeToThermalState() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(thermalStateDidChange),
            name: ProcessInfo.thermalStateDidChangeNotification,
            object: nil
        )
    }

    @objc private func thermalStateDidChange() {
        let state = ProcessInfo.processInfo.thermalState
        switch state {
        case .serious:
            triggerProfiler(durationInSeconds: 30, reason: .thermalSerious, desc: "iOS thermal state: serious")
        case .critical:
            triggerProfiler(durationInSeconds: 30, reason: .thermalCritical, desc: "iOS thermal state: critical")
        default:
            break
        }
    }

    private func subscribeToMemoryPressure() {
        let source = DispatchSource.makeMemoryPressureSource(eventMask: [.warning, .critical], queue: .main)
        source.setEventHandler { [weak self] in
            let event = source.data
            Task { @MainActor [weak self] in
                guard let self else { return }
                if event.contains(.critical) {
                    self.triggerProfiler(durationInSeconds: 0, reason: .memoryPressureCritical, desc: "iOS memory pressure: critical")
                } else if event.contains(.warning) {
                    self.triggerProfiler(durationInSeconds: 0, reason: .memoryPressureWarn, desc: "iOS memory pressure: warning")
                }
            }
        }
        source.resume()
        memoryPressureSource = source
    }

    private func triggerProfiler(durationInSeconds: Int32, reason: DebugProfilerReason, desc: String) {
        let isTimed = durationInSeconds > 0
        let cooldown = isTimed ? Constants.timedProfilerCooldown : Constants.instantProfilerCooldown
        let now = Date()
        let last = isTimed ? lastTimedProfilerDate : lastInstantProfilerDate
        if let last, now.timeIntervalSince(last) < cooldown {
            log.debug("Profiler skipped (cooldown): \(reason)")
            return
        }
        if isTimed {
            lastTimedProfilerDate = now
        } else {
            lastInstantProfilerDate = now
        }
        log.debug("Profiler triggered: \(reason), duration: \(durationInSeconds)s")
        Task {
            await debugService.runProfiler(durationInSeconds: durationInSeconds, reason: reason, reasonDesc: desc)
        }
    }
}
