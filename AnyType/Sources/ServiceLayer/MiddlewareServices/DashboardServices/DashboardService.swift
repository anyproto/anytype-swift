//
//  DashboardService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 18.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels
import ProtobufMessages

class DashboardService: DashboardServiceProtocol {
    private let middlewareConfigurationService: MiddlewareConfigurationService = .init()
    private let blocksActionsService: BlockActionsServiceSingle = .init()
    private let objectsService: ObjectActionsService = .init()
    private var dashboardId: String = ""
    
    private func save(configuration: MiddlewareConfigurationService.MiddlewareConfiguration) -> MiddlewareConfigurationService.MiddlewareConfiguration {
        self.dashboardId = configuration.homeBlockID
        return configuration
    }
        
    func openDashboard() -> AnyPublisher<ServiceSuccess, Error> {
        self.middlewareConfigurationService.obtainConfiguration().flatMap { [unowned self] configuration in
            self.blocksActionsService.open(
                contextID: configuration.homeBlockID, blockID: configuration.homeBlockID
            )
        }.eraseToAnyPublisher()
    }
    
    func createNewPage(contextId: String) -> AnyPublisher<ServiceSuccess, Error> {
        let targetId: String = ""
        let details: DetailsInformationModelProtocol = TopLevel.Builder.detailsBuilder.informationBuilder.build(list: [
            .title(.init()),
            .iconEmoji(.init())
        ])
                
        return objectsService.createPage(contextID: contextId, targetID: targetId, details: details, position: .bottom)
    }
}
