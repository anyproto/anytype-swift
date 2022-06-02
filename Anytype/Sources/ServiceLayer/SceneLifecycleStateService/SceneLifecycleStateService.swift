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
        switch transition {
        case .willEnterForeground:
            let result = Anytype_Rpc.App.SetDeviceState.Service.invoke(deviceState: .foreground)
            handleResult(result)
        case .didEnterBackground:
            let result = Anytype_Rpc.App.SetDeviceState.Service.invoke(deviceState: .background)
            handleResult(result)
        }
    }
    
    // MARK: - Private func
    
    private func handleResult(_ result: Result<Anytype_Rpc.App.SetDeviceState.Response, Error>) {
        switch result {
        case .success(let response):
            let error = response.error
            switch error.code {
            case .null: return
            case .unknownError, .badInput, .nodeNotStarted, .UNRECOGNIZED:
                anytypeAssertionFailure(error.description_p, domain: .sceneLifecycleStateService)
            }
        case .failure(let error):
            anytypeAssertionFailure(error.localizedDescription, domain: .sceneLifecycleStateService)
        }
    }
    
}

