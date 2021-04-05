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
protocol SmartBlockActionsServiceProtocolCreatePage {
    associatedtype Success
    typealias DetailsInformation = DetailsInformationModelProtocol
    typealias Position = TopLevel.Position
    func action(contextID: BlockId, targetID: BlockId, details: DetailsInformation, position: Position) -> AnyPublisher<Success, Error>
}

/// Protocol for set details action.
/// NOTE: You have to convert value to List<Anytype_Rpc.Block.Set.Details.Detail>.
protocol SmartBlockActionsServiceProtocolSetDetails {
    associatedtype Success
    typealias DetailsContent = TopLevel.DetailsContent
    func action(contextID: BlockId, details: DetailsContent) -> AnyPublisher<Success, Error>
}

/// Protocol for convert children to page action.
/// NOTE: Action supports List context.
protocol SmartBlockActionsServiceProtocolConvertChildrenToPages {
    func action(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<Void, Error>
}

// MARK: - Service Protocol
/// Protocol for SmartBlock actions services.
protocol SmartBlockActionsServiceProtocol {
    associatedtype CreatePage: SmartBlockActionsServiceProtocolCreatePage
    associatedtype SetDetails: SmartBlockActionsServiceProtocolSetDetails
    associatedtype ConvertChildrenToPages: SmartBlockActionsServiceProtocolConvertChildrenToPages
    
    var createPage: CreatePage {get}
    var setDetails: SetDetails {get}
    var convertChildrenToPages: ConvertChildrenToPages {get}
}
