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

class DashboardService: DashboardServiceProtocol {
    private let middlewareConfigurationService: MiddlewareConfigurationService = .init()
    private let blocksActionsService: BlockActionsService = .init()
    private var dashboardId: String = ""
    
    private func save(configuration: MiddlewareConfigurationService.MiddlewareConfiguration) -> MiddlewareConfigurationService.MiddlewareConfiguration {
        self.dashboardId = configuration.homeBlockID
        return configuration
    }
    
    // TODO: Fix potential memory leak in `.map(self.save(configuration:))`
    func subscribeDashboardEvents() -> AnyPublisher<Never, Error> {
        middlewareConfigurationService.obtainConfiguration().map(self.save(configuration:))
            .flatMap { [unowned self] cunfiguration -> AnyPublisher<Never, Error> in
                return self.blocksActionsService.open.action(contextID: cunfiguration.homeBlockID, blockID: cunfiguration.homeBlockID)
        }
        .ignoreOutput()
        .eraseToAnyPublisher()
    }
    
    func obtainDashboardBlocks() -> AnyPublisher<Anytype_Event.Block.Show, Never> {
        middlewareConfigurationService.obtainConfiguration().ignoreFailure().flatMap({ [unowned self] configuration in
        self.blocksActionsService.eventListener.receiveRawEvent(contextId: configuration.homeBlockID) }).eraseToAnyPublisher()
    }
    
    func createPage(contextId: String) -> AnyPublisher<Void, Error> {
        var emptyPageBlock = Anytype_Model_Block()
        var pageContent = Anytype_Model_Block.Content.Page()
        pageContent.style = .empty
        emptyPageBlock.content = Anytype_Model_Block.OneOf_Content.page(pageContent)
        emptyPageBlock.fields = emptyPageBlock.fields
        emptyPageBlock.fields.fields = emptyPageBlock.fields.fields
        emptyPageBlock.fields.fields["icon"] = .init(stringValue: "")
        emptyPageBlock.fields.fields["name"] = .init(stringValue: "Untitled")
        
        return Anytype_Rpc.Block.Create.Service.invoke(contextID: contextId, targetID: "", block: emptyPageBlock, position: .bottom)
            .successToVoid()
            .eraseToAnyPublisher()
    }
}
