//
//  ProfileService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 04.12.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Combine

class ProfileService: ProfileServiceProtocol {
    var name: String?
    var avatar: String?
    
    private let middlewareConfigurationService: MiddlewareConfigurationService = .init()
    private let blocksActionsService: ServiceLayerModule.Single.BlockActionsService = .init()
    
    func obtainUserInformation() -> AnyPublisher<ServiceLayerModule.Success, Error> {
        self.middlewareConfigurationService.obtainConfiguration().flatMap { [unowned self] configuration in
            self.blocksActionsService.open.action(contextID: configuration.profileBlockId, blockID: configuration.profileBlockId)
        }.eraseToAnyPublisher()
    }
}
