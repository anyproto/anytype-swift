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

    private let storage = InMemoryStoreFacade.shared.middlewareConfigurationStore

    // TODO: Rethink result type.
    // Maybe we would like to return Result?
    private func save(configuration: MiddlewareConfiguration) {
        storage?.add(configuration)
    }

    /// Obtain middleware configuration
    func obtainConfiguration() -> AnyPublisher<MiddlewareConfiguration, Error> {
        let configuration = storage?.get(by: MiddlewareConfiguration.self)

        if let configuration = configuration {
            return Just(configuration)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Anytype_Rpc.Config.Get.Service.invoke()
            .subscribe(on: DispatchQueue.global())
            .map(\.homeBlockID, \.archiveBlockID, \.gatewayURL)
            .map(MiddlewareConfiguration.init)
            .map { [weak self] configuration in
                self?.storage?.add(configuration)
                return configuration
            }
            .eraseToAnyPublisher()
    }
}
