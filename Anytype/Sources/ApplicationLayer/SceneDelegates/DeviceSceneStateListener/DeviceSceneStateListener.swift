import Services

protocol DeviceSceneStateListenerProtocol {
    func start()
}

final class DeviceSceneStateListener: DeviceSceneStateListenerProtocol, SceneStateListener {
    
    private let lifecycleStateService: SceneLifecycleStateServiceProtocol = SceneLifecycleStateService()
    private let sceneStateNotifier = ServiceLocator.shared.sceneStateNotifier()
    
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
