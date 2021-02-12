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

protocol ServiceLayerModule_BlockActionsServiceSingleProtocolOpen {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockActionsServiceSingleProtocolClose {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Void, Error>
}

protocol ServiceLayerModule_BlockActionsServiceSingleProtocolAdd {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Model = BlockInformationModelProtocol
    typealias Position = BlocksModelsModule.Parser.Common.Position.Position
    func action(contextID: BlockId, targetID: BlockId, block: Model, position: Position) -> AnyPublisher<Success, Error>
}


protocol ServiceLayerModule_BlockActionsServiceSingleProtocolReplace {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Model = BlockInformationModelProtocol
    func action(contextID: BlockId, blockID: BlockId, block: Model) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockActionsServiceSingleProtocolDelete {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockIds: [BlockId]) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockListActionsServiceProtocolDuplicate {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Position = BlocksModelsModule.Parser.Common.Position.Position
    func action(contextID: BlockId, targetID: BlockId, blockIds: [BlockId], position: Position) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockActionsServiceSingleProtocol {
    associatedtype Open: ServiceLayerModule_BlockActionsServiceSingleProtocolOpen
    associatedtype Close: ServiceLayerModule_BlockActionsServiceSingleProtocolClose
    associatedtype Add: ServiceLayerModule_BlockActionsServiceSingleProtocolAdd
    associatedtype Replace: ServiceLayerModule_BlockActionsServiceSingleProtocolReplace
    associatedtype Delete: ServiceLayerModule_BlockActionsServiceSingleProtocolDelete
    associatedtype Duplicate: ServiceLayerModule_BlockListActionsServiceProtocolDuplicate
    
    var open: Open {get}
    var close: Close {get}
    var add: Add {get}
    var replace: Replace {get}
    var delete: Delete {get}
    var duplicate: Duplicate {get}
}
