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

class DashboardService: DashboardServiceProtocol {
    private let middlewareConfigurationService: MiddlewareConfigurationService = .init()
    private let blocksActionsService: ServiceLayerModule.Single.BlockActionsService = .init()
    private let smartBlockService: ServiceLayerModule.SmartBlockActionsService = .init()
    private var dashboardId: String = ""
    
    private func save(configuration: MiddlewareConfigurationService.MiddlewareConfiguration) -> MiddlewareConfigurationService.MiddlewareConfiguration {
        self.dashboardId = configuration.homeBlockID
        return configuration
    }
    
    func subscribeDashboardEvents() -> AnyPublisher<[Anytype_Event.Message], Error> {
        middlewareConfigurationService.obtainConfiguration()
            .flatMap { [unowned self] cunfiguration in
                return self.blocksActionsService.open.action(contextID: cunfiguration.homeBlockID, blockID: cunfiguration.homeBlockID)
        }.map(\.messages)
        .eraseToAnyPublisher()
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
        let position: BlocksModelsModule.Parser.Common.Position.Position = .bottom
                
        return self.smartBlockService.createPage.action(contextID: contextId, targetID: targetId, details: details, position: position)
    }
}
