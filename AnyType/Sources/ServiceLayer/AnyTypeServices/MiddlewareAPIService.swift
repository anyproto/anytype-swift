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
    typealias MiddlwareConfig = MiddlewareModels.MiddlwareConfig
    
    /// Obtain middleware config
    /// - Parameter completion: called on completion
    func obtainConfig() -> AnyPublisher<MiddlwareConfig, Error> {
        Anytype_Rpc.Config.Get.Service.invoke()
            .subscribe(on: DispatchQueue.global())
            .map { response in
                let configModel = MiddlewareModels.MiddlwareConfig(homeBlockID: response.homeBlockID, archiveBlockID: response.archiveBlockID, gatewayURL: response.gatewayURL)
                InMemoryStore.shared.add(service: configModel)
                
                return configModel
        }
        .eraseToAnyPublisher()
    }
}

/// Dashboard service
class DashboardService {
    private let middleConfigService = MiddleConfigService()
    
    func openDashboard() -> AnyPublisher<Never, Error> {
        middleConfigService.obtainConfig()
            .flatMap { config in
                Anytype_Rpc.Block.Open.Service.invoke(contextID: config.homeBlockID, blockID: config.homeBlockID, breadcrumbsIds: [])
                    .subscribe(on: DispatchQueue.global())
                    .ignoreOutput()
        }
        .eraseToAnyPublisher()
    }
}
