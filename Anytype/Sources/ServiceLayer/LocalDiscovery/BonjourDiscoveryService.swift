import Foundation
import UIKit
import ProtobufMessages

protocol BonjourDiscoveryServiceProtocol: LocalDiscoveryProxy {
    @MainActor
    func start()
}

/// Middleware's discovery proxy on iOS. Feeds the engine middleware's observer (from any thread)
/// and the scene lifecycle (from main), hopping onto the engine's serial queue.
final class BonjourDiscoveryService: BonjourDiscoveryServiceProtocol {

    private let queue: DispatchQueue
    private let engine: BonjourDiscoveryEngine

    init() {
        let queue = DispatchQueue(label: "io.anytype.localdiscovery")
        self.queue = queue
        self.engine = BonjourDiscoveryEngine(
            client: DNSServiceClient(queue: queue),
            scheduler: DispatchQueueLocalDiscoveryScheduler(queue: queue)
        )
    }

    // MARK: - BonjourDiscoveryServiceProtocol

    @MainActor
    func start() {
        // Observed synchronously from launch: the first foreground notification is posted right after
        // didFinishLaunching. A cold launch into the background posts none, so discovery stays off.
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIScene.willEnterForegroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIScene.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didActivate),
            name: UIScene.didActivateNotification,
            object: nil
        )
        let isForeground = UIApplication.shared.connectedScenes.contains {
            $0.activationState == .foregroundActive || $0.activationState == .foregroundInactive
        }
        if isForeground {
            willEnterForeground()
        }
    }

    // MARK: - LocalDiscoveryProxy

    func setObserver(_ observer: any LocalDiscoveryObserver) {
        queue.async { [engine] in
            engine.setObserver(observer)
        }
    }

    func removeObserver() {
        queue.async { [engine] in
            engine.removeObserver()
        }
    }

    // MARK: - Scene lifecycle

    @objc @MainActor
    private func willEnterForeground() {
        queue.async { [engine] in
            engine.setForeground(true)
        }
    }

    /// The Local Network prompt deactivates the scene while it is shown: once it is dismissed,
    /// a denial it raised before the user answered gets retried.
    @objc @MainActor
    private func didActivate() {
        queue.async { [engine] in
            engine.sceneDidActivate()
        }
    }

    /// The background task keeps the app alive until the registration is deallocated, so the goodbye goes out.
    @objc @MainActor
    private func didEnterBackground() {
        let backgroundTask = BonjourDiscoveryBackgroundTask()
        backgroundTask.begin()
        queue.async { [engine] in
            engine.setForeground(false)
            Task { @MainActor in
                backgroundTask.end()
            }
        }
    }
}

@MainActor
private final class BonjourDiscoveryBackgroundTask {

    private var identifier: UIBackgroundTaskIdentifier = .invalid

    func begin() {
        identifier = UIApplication.shared.beginBackgroundTask(withName: "BonjourDiscoveryStop") { [weak self] in
            self?.end()
        }
    }

    func end() {
        guard identifier != .invalid else { return }
        UIApplication.shared.endBackgroundTask(identifier)
        identifier = .invalid
    }
}
