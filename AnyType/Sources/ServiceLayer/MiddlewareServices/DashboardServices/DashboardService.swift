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
