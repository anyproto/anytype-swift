//
//  LifecycleStateTransitionSceneDelegate.swift
//  Anytype
//
//  Created by Konstantin Mordan on 27.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import UIKit

final class LifecycleStateTransitionSceneDelegate: NSObject, UIWindowSceneDelegate {
    
    private let lifecycleStateService = SceneLifecycleStateService()
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        lifecycleStateService.handleStateTransition(.willEnterForeground)
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        lifecycleStateService.handleStateTransition(.didEnterBackground)
    }
    
}
