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
    private let middleConfigService: MiddleConfigService = .init()
    private let blocksActionsService: BlockActionsService = .init()
    private var dashboardId: String = ""
    func subscribeDashboardEvents() -> AnyPublisher<Never, Error> {
        middleConfigService.obtainConfig()
            .flatMap { [unowned self] config -> AnyPublisher<Never, Error> in
                self.dashboardId = config.homeBlockID
                return self.blocksActionsService.open.action(contextID: config.homeBlockID, blockID: config.homeBlockID)
        }
        .ignoreOutput()
        .eraseToAnyPublisher()
    }
    
    func obtainDashboardBlocks() -> AnyPublisher<Anytype_Event.Block.Show, Never> {
        middleConfigService.obtainConfig().ignoreFailure().flatMap({ [unowned self] configuration in
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
