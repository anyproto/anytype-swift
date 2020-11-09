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
    private let storage = InMemoryStoreFacade.shared.middlewareConfigurationStore

    // TODO: Rethink result type.
    // Maybe we would like to return Result?
    private func save(configuration: MiddlewareConfiguration) {
        self.storage?.add(configuration)
    }

    /// Obtain middleware configuration
    func obtainConfiguration() -> AnyPublisher<MiddlewareConfiguration, Error> {
        let configuration = self.storage?.get(by: MiddlewareConfiguration.self)

        if let configuration = configuration {
            return Just(configuration)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }

        return Anytype_Rpc.Config.Get.Service.invoke()
            .subscribe(on: DispatchQueue.global())
            .map({($0.homeBlockID, $0.archiveBlockID, $0.profileBlockID, $0.gatewayURL)})
            .map(MiddlewareConfiguration.init)
            .map { [weak self] configuration in
                self?.storage?.add(configuration)
                return configuration
            }
            .eraseToAnyPublisher()
    }
    
    func obtainLibraryVersion() -> AnyPublisher<MiddlewareVersion, Error> {
        Anytype_Rpc.Version.Get.Service.invoke()
            .map(\.details)
            .map(MiddlewareVersion.init(version:))
            .subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}
