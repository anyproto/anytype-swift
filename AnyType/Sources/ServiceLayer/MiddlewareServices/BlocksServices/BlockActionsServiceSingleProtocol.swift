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

protocol BlockActionsServiceSingleProtocolOpen {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Success, Error>
}

protocol BlockActionsServiceSingleProtocolClose {
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockID: BlockId) -> AnyPublisher<Void, Error>
}

protocol BlockActionsServiceSingleProtocolAdd {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Position = TopLevel.AliasesMap.Position
    func action(contextID: BlockId, targetID: BlockId, block: Block.Information.InformationModel, position: Position) -> AnyPublisher<Success, Error>
}


protocol BlockActionsServiceSingleProtocolReplace {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockID: BlockId, block: Block.Information.InformationModel) -> AnyPublisher<Success, Error>
}

protocol BlockActionsServiceSingleProtocolDelete {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    func action(contextID: BlockId, blockIds: [BlockId]) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockListActionsServiceProtocolDuplicate {
    associatedtype Success
    typealias BlockId = TopLevel.AliasesMap.BlockId
    typealias Position = TopLevel.AliasesMap.Position
    func action(contextID: BlockId, targetID: BlockId, blockIds: [BlockId], position: Position) -> AnyPublisher<Success, Error>
}

protocol BlockActionsServiceSingleProtocol {
    associatedtype Open: BlockActionsServiceSingleProtocolOpen
    associatedtype Close: BlockActionsServiceSingleProtocolClose
    associatedtype Add: BlockActionsServiceSingleProtocolAdd
    associatedtype Replace: BlockActionsServiceSingleProtocolReplace
    associatedtype Delete: BlockActionsServiceSingleProtocolDelete
    associatedtype Duplicate: ServiceLayerModule_BlockListActionsServiceProtocolDuplicate
    
    var open: Open {get}
    var close: Close {get}
    var add: Add {get}
    var replace: Replace {get}
    var delete: Delete {get}
    var duplicate: Duplicate {get}
}
