//
//  SceneLifecycleStateService.swift
//  Anytype
//
//  Created by Konstantin Mordan on 27.05.2022.
//  Copyright © 2022 Anytype. All rights reserved.
//

import Foundation
import ProtobufMessages
import AnytypeCore

/// Middleware should know about current app state in order to correctly handling socket listening
/// @see https://developer.apple.com/library/archive/technotes/tn2277/_index.html#//apple_ref/doc/uid/DTS40010841-CH1-SUBSECTION2
final class SceneLifecycleStateService {
    
    // MARK: - Internal func
    
    func handleStateTransition(_ transition: LifecycleStateTransition) {
        let deviceState: Anytype_Rpc.App.SetDeviceState.Request.DeviceState = {
            switch transition {
            case .willEnterForeground: return .foreground
            case .didEnterBackground: return .background
            }
        }()
        
        _ = try? ClientCommands.appSetDeviceState(.with {
            $0.deviceState = deviceState
        }).invoke()
    }
    
}

