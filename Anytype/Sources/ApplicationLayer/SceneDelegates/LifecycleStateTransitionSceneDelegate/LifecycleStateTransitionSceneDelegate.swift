import Foundation
import UIKit
import Services

final class LifecycleStateTransitionSceneDelegate: NSObject, UIWindowSceneDelegate {
    
    private let lifecycleStateService: SceneLifecycleStateServiceProtocol = SceneLifecycleStateService()
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        lifecycleStateService.handleStateTransition(.willEnterForeground)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        lifecycleStateService.handleStateTransition(.didEnterBackground)
    }
    
}
