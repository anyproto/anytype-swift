//
//  DashboardService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 18.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import SwiftProtobuf
import BlocksModels

class DashboardService: DashboardServiceProtocol {
    private let middlewareConfigurationService: MiddlewareConfigurationService = .init()
    private let blocksActionsService: ServiceLayerModule.BlockActionsService = .init()
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
        let position: Anytype_Model_Block.Position = .bottom
        
        let titleId = TopLevel.AliasesMap.DetailsContent.Title.id
        let iconEmoji = TopLevel.AliasesMap.DetailsContent.Emoji.id
        let details: Google_Protobuf_Struct = .init(fields: [
            titleId : .init(stringValue: ""),
            iconEmoji : .init(stringValue: "")
        ])
        
        let targetId: String = ""
                
        return self.smartBlockService.createPage.action(contextID: contextId, targetID: targetId, details: details, position: position)
    }
    
    func createPage(contextId: String) -> AnyPublisher<[Anytype_Event.Message], Error> {
        
        let position: Anytype_Model_Block.Position = .bottom
        
        let titleId = TopLevel.AliasesMap.DetailsContent.Title.id
        let iconEmoji = TopLevel.AliasesMap.DetailsContent.Emoji.id
        let details: Google_Protobuf_Struct = .init(fields: [
            titleId : .init(stringValue: ""),
            iconEmoji : .init(stringValue: "")
        ])
        
        return Anytype_Rpc.Block.CreatePage.Service.invoke(contextID: contextId, targetID: "", details: details, position: position)
            .map(\.event).map(\.messages)
            .eraseToAnyPublisher()
    }
}
