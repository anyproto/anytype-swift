//
//  ConfigurationService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 18.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

/// Service that handles middleware config
class MiddlewareConfigurationService: ConfigurationServiceProtocol {
    typealias MiddlewareConfiguration = MiddlewareConfigurationService.MiddlewareConfiguration
    
    // TODO: Rethink result type.
    // Maybe we would like to return Result?
    func save(configuration: MiddlewareConfiguration) -> MiddlewareConfiguration {
        let storage = InMemoryStoreFacade.shared.middlewareConfigurationStore
        storage?.add(configuration)
//        let value = storage?.get(by: MiddlewareConfiguration.self)
        return configuration
    }

    /// Obtain middleware configuration
    // TODO: Fix potential memory leak in `.map(save(configuration:))`
    func obtainConfiguration() -> AnyPublisher<MiddlewareConfiguration, Error> {
        Anytype_Rpc.Config.Get.Service.invoke()
        .subscribe(on: DispatchQueue.global())
        .map({ ($0.homeBlockID, $0.archiveBlockID, $0.gatewayURL) })
        .map(MiddlewareConfiguration.init)
        .map(self.save(configuration:))
        .eraseToAnyPublisher()
    }
}
