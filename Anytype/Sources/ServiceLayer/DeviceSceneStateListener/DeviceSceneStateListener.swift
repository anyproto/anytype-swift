import Services
import Factory

protocol DeviceSceneStateListenerProtocol {
    func start()
}

final class DeviceSceneStateListener: DeviceSceneStateListenerProtocol, SceneStateListener {
    
    @Injected(\.sceneLifecycleStateService)
    private var lifecycleStateService: SceneLifecycleStateServiceProtocol
    @Injected(\.sceneStateNotifier)
    private var sceneStateNotifier: SceneStateNotifierProtocol
    
    // MARK: - DeviceSceneStateListenerProtocol
    
    func start() {
        sceneStateNotifier.addListener(self)
    }
    
    // MARK: - SceneStateListener
    
    func willEnterForeground() {
        lifecycleStateService.handleStateTransition(.willEnterForeground)
    }
    
    func didEnterBackground() {
        lifecycleStateService.handleStateTransition(.didEnterBackground)
    }
    
}
