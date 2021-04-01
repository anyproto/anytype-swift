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
    private let blocksActionsService: BlockActionsServiceSingle = .init()
    
    func obtainUserInformation() -> AnyPublisher<ServiceSuccess, Error> {
        self.middlewareConfigurationService.obtainConfiguration().flatMap { [unowned self] configuration in
            self.blocksActionsService.open(contextID: configuration.profileBlockId, blockID: configuration.profileBlockId)
        }.eraseToAnyPublisher()
    }
}
