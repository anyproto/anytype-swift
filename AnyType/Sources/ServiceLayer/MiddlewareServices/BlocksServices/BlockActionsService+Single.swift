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

fileprivate typealias Namespace = ServiceLayerModule.Single

protocol ServiceLayerModule_BlockActionsServiceSingleProtocolOpen {
    associatedtype Success
    func action(contextID: String, blockID: String) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockActionsServiceSingleProtocolClose {
    func action(contextID: String, blockID: String) -> AnyPublisher<Void, Error>
}

protocol ServiceLayerModule_BlockActionsServiceSingleProtocolAdd {
    associatedtype Success
    func action(contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error>
}


protocol ServiceLayerModule_BlockActionsServiceSingleProtocolReplace {
    associatedtype Success
    func action(contextID: String, blockID: String, block: Anytype_Model_Block) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockActionsServiceSingleProtocolDelete {
    associatedtype Success
    func action(contextID: String, blockIds: [String]) -> AnyPublisher<Success, Error>
}

protocol ServiceLayerModule_BlockListActionsServiceProtocolDuplicate {
    associatedtype Success
    func action(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error>
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

extension Namespace {
    class BlockActionsService: ServiceLayerModule_BlockActionsServiceSingleProtocol {
        typealias ContextId = String
        
        var open: Open = .init() // SmartBlock only for now?
        var close: Close = .init() // SmartBlock only for now?
        var add: Add = .init()
        var replace: Replace = .init()
        var delete: Delete = .init()
        var duplicate: Duplicate = .init() // BlockList?
    }
}

// MARK: Actions
extension Namespace.BlockActionsService {
    typealias Success = ServiceLayerModule.Success
    
    // MARK: Open / Close
    struct Open: ServiceLayerModule_BlockActionsServiceSingleProtocolOpen {
        func action(contextID: String, blockID: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Open.Service.invoke(contextID: contextID, blockID: blockID).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Close: ServiceLayerModule_BlockActionsServiceSingleProtocolClose {
        func action(contextID: String, blockID: String) -> AnyPublisher<Void, Error> {
            Anytype_Rpc.Block.Close.Service.invoke(contextID: contextID, blockID: blockID).successToVoid().subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: Create (OR Add) / Replace / Unlink ( OR Delete )
    struct Add: ServiceLayerModule_BlockActionsServiceSingleProtocolAdd {
        func action(contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Create.Service.invoke(contextID: contextID, targetID: targetID, block: block, position: position)
                .map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
        
    struct Replace: ServiceLayerModule_BlockActionsServiceSingleProtocolReplace {
        func action(contextID: String, blockID: String, block: Anytype_Model_Block) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Replace.Service.invoke(contextID: contextID, blockID: blockID, block: block).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Delete: ServiceLayerModule_BlockActionsServiceSingleProtocolDelete {
        func action(contextID: String, blockIds: [String]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextID, blockIds: blockIds).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
        
    // MARK: Duplicate
    // Actually, should be used for BlockList
    struct Duplicate: ServiceLayerModule_BlockListActionsServiceProtocolDuplicate {
        func action(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Duplicate.Service.invoke(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
}
