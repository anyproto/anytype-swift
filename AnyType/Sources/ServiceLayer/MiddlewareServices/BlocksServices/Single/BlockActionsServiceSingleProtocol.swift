//
//  BlockActionsService+Single.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 14.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import BlocksModels

protocol BlockActionsServiceSingleProtocol {
    typealias BlockId = TopLevel.BlockId
    typealias Position = TopLevel.Position
    
    func delete(contextID: BlockId, blockIds: [BlockId]) -> AnyPublisher<ServiceSuccess, Error>
    func duplicate(contextID: BlockId, targetID: BlockId, blockIds: [BlockId], position: Position) -> AnyPublisher<ServiceSuccess, Error>
    func replace(contextID: BlockId, blockID: BlockId, block: Block.Information.InformationModel) -> AnyPublisher<ServiceSuccess, Error>
    func add(contextID: BlockId, targetID: BlockId, block: Block.Information.InformationModel, position: Position) -> AnyPublisher<ServiceSuccess, Error>
    func close(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Void, Error>
    func open(contextID: BlockId, blockID: BlockId) -> AnyPublisher<ServiceSuccess, Error>
}
