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
    private let blocksActionsService: ServiceLayerModule.Single.BlockActionsService = .init()
    private let smartBlockService: ServiceLayerModule.SmartBlockActionsService = .init()
    private var dashboardId: String = ""
    
    private func save(configuration: MiddlewareConfigurationService.MiddlewareConfiguration) -> MiddlewareConfigurationService.MiddlewareConfiguration {
        self.dashboardId = configuration.homeBlockID
        return configuration
    }
        
    func openDashboard() -> AnyPublisher<ServiceLayerModule.Success, Error> {
        self.middlewareConfigurationService.obtainConfiguration().flatMap { [unowned self] configuration in
            self.blocksActionsService.open.action(contextID: configuration.homeBlockID, blockID: configuration.homeBlockID)
        }.eraseToAnyPublisher()
    }
    
    func createNewPage(contextId: String) -> AnyPublisher<ServiceLayerModule.Success, Error> {
        let targetId: String = ""
        let details: DetailsInformationModelProtocol = TopLevel.Builder.detailsBuilder.informationBuilder.build(list: [
            .title(.init()),
            .iconEmoji(.init())
        ])
                
        return self.smartBlockService.createPage.action(contextID: contextId, targetID: targetId, details: details, position: .bottom)
    }
}
