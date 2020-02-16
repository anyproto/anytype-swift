//
//  MiddlewareAPIService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 16.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Lib
import Combine

/// Service that handles middleware config
class MiddleConfigService {
    /// Obtain middleware config
    /// - Parameter completion: called on completion
    func obtainConfig(completion: @escaping (_ result: Result<Void, Error>) -> Void) {
        _ = Anytype_Rpc.Config.Get.Service.invoke()
            .subscribe(on: DispatchQueue.global())
            .sink(receiveCompletion: { result in
                switch result {
                case .finished:
                    break
                case .failure(let error):
                    completion(Result.failure(error))
                }
            }) { response in
                let configModel = MiddlewareModels.MiddlwareConfig(homeBlockID: response.homeBlockID, archiveBlockID: response.archiveBlockID, gatewayURL: response.gatewayURL)
                InMemoryStore.shared.add(service: configModel)
        }
    }
}

/// Dashboard service
class DashboardService {

    func openDashboard(blockID: String) {
        Anytype_Rpc.Block.Open.Service.invoke(contextID: "", blockID: "", breadcrumbsIds: [])
    }
}
