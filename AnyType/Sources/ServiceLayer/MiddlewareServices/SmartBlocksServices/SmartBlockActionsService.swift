//
//  SmartBlockActionsService.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 14.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels

// MARK: - Actions Protocols
/// Protocol for create page action.
/// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
protocol ServiceLayerModule_SmartBlockActionsServiceProtocolCreatePage {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias DetailsInformation = DetailsInformationModelProtocol
    typealias Position = BlocksModelsModule.Parser.Common.Position.Position
    func action(contextID: BlockId, targetID: BlockId, details: DetailsInformation, position: Position) -> AnyPublisher<Success, Error>
}

/// Protocol for set details action.
/// NOTE: You have to convert value to List<Anytype_Rpc.Block.Set.Details.Detail>.
protocol ServiceLayerModule_SmartBlockActionsServiceProtocolSetDetails {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias DetailsContent = TopLevel.AliasesMap.DetailsContent
    func action(contextID: BlockId, details: DetailsContent) -> AnyPublisher<Success, Error>
}

/// Protocol for convert children to page action.
/// NOTE: Action supports List context.
protocol ServiceLayerModule_SmartBlockActionsServiceProtocolConvertChildrenToPages {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<Void, Error>
}

// MARK: - Service Protocol
/// Protocol for SmartBlock actions services.
protocol ServiceLayerModule_SmartBlockActionsServiceProtocol {
    associatedtype CreatePage: ServiceLayerModule_SmartBlockActionsServiceProtocolCreatePage
    associatedtype SetDetails: ServiceLayerModule_SmartBlockActionsServiceProtocolSetDetails
    associatedtype ConvertChildrenToPages: ServiceLayerModule_SmartBlockActionsServiceProtocolConvertChildrenToPages
    
    var createPage: CreatePage {get}
    var setDetails: SetDetails {get}
    var convertChildrenToPages: ConvertChildrenToPages {get}
}
