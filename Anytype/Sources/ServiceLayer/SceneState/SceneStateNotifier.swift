import UIKit
import AnytypeCore

@MainActor
protocol SceneStateNotifierProtocol {
    func addListener(_ listner: some SceneStateListener)
    func willEnterForeground(_ notification: Notification)
    func didEnterBackground(_ notification: Notification)
}

@MainActor
final class SceneStateNotifier: SceneStateNotifierProtocol {
    private var listeners: [Weak<any SceneStateListener>] = []
    
    nonisolated init() {
        Task {
            await setupObservers()
        }
    }
    
    // MARK: - SceneStateNotifierProtocol
    
    func addListener(_ listner: some SceneStateListener) {
        cleanListeners()
        listeners.append(Weak(value: listner))
    }
    
    @objc func willEnterForeground(_ notification: Notification) {
        listeners.forEach { listener in
            listener.value?.willEnterForeground()
        }
    }
    
    @objc func didEnterBackground(_ notification: Notification) {
        listeners.forEach { listener in
            listener.value?.didEnterBackground()
        }
    }
    
    // MARK: - Private
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didEnterBackground),
            name: UIScene.didEnterBackgroundNotification,
            object: nil
        )

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(willEnterForeground),
            name: UIScene.willEnterForegroundNotification,
            object: nil
        )
    }
    
    private func cleanListeners() {
        listeners = listeners.filter { $0.value.isNotNil }
    }
}
