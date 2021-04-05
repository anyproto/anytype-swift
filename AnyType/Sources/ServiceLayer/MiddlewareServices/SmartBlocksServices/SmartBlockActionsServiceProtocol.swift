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


// MARK: - Service Protocol
/// Protocol for SmartBlock actions services.
protocol SmartBlockActionsServiceProtocol {
    /// Protocol for convert children to page action.
    /// NOTE: Action supports List context.
    func convertChildrenToPages(contextID: BlockId, blocksIds: [BlockId]) -> AnyPublisher<Void, Error>
    
    /// Protocol for set details action.
    /// NOTE: You have to convert value to List<Anytype_Rpc.Block.Set.Details.Detail>.
    func setDetails(contextID: BlockId, details: DetailsContent) -> AnyPublisher<ServiceSuccess, Error>
    
    // MARK: - Actions Protocols
    /// Protocol for create page action.
    /// NOTE: `CreatePage` action will return block of type `.link(.page)`. (!!!)
    typealias DetailsInformation = DetailsInformationModelProtocol
    typealias Position = TopLevel.Position
    func createPage(contextID: BlockId, targetID: BlockId, details: DetailsInformation, position: Position) -> AnyPublisher<ServiceSuccess, Error>
}
