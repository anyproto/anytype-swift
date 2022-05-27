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

final class SceneLifecycleStateService {
    
    // MARK: - Internal func
    
    func handleStateTransition(_ transition: LifecycleStateTransition) {
        switch transition {
        case .willEnterForeground:
            let result = Anytype_Rpc.DeviceState.Service.invoke(deviceState: .foreground)
            handleResult(result)
        case .didEnterBackground:
            let result = Anytype_Rpc.DeviceState.Service.invoke(deviceState: .background)
            handleResult(result)
        }
    }
    
    // MARK: - Private func
    
    private func handleResult(_ result: Result<Anytype_Rpc.DeviceState.Response, Error>) {
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

