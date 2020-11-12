//
//  BlockActionService+Single.swift
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
    func action(contextID: String, blockID: String) -> AnyPublisher<Never, Error>
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

protocol ServiceLayerModule_BlockEventListener {
    associatedtype Event
    func receive(contextId: String) -> AnyPublisher<Event, Never>
}

protocol ServiceLayerModule_BlockActionsServiceSingleProtocol {
    associatedtype Open: ServiceLayerModule_BlockActionsServiceSingleProtocolOpen
    associatedtype Close: ServiceLayerModule_BlockActionsServiceSingleProtocolClose
    associatedtype Add: ServiceLayerModule_BlockActionsServiceSingleProtocolAdd
    associatedtype Replace: ServiceLayerModule_BlockActionsServiceSingleProtocolReplace
    associatedtype Delete: ServiceLayerModule_BlockActionsServiceSingleProtocolDelete
    associatedtype Duplicate: ServiceLayerModule_BlockListActionsServiceProtocolDuplicate
    associatedtype EventListener: ServiceLayerModule_BlockEventListener
    
    var open: Open {get}
    var close: Close {get}
    var add: Add {get}
    var replace: Replace {get}
    var delete: Delete {get}
    var duplicate: Duplicate {get}
    var eventListener: EventListener {get}
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
        var eventListener: EventListener = .init()
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
        func action(contextID: String, blockID: String) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.Block.Close.Service.invoke(contextID: contextID, blockID: blockID).ignoreOutput().subscribe(on: DispatchQueue.global())
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

extension Namespace.BlockActionsService {
    // MARK: Events Processing
    // MARK: It is new Listener, so, you should replace old listener.
    struct EventListener: ServiceLayerModule_BlockEventListener {
        private static let parser: BlocksModelsModule.Parser = .init()
        
         struct Event {
             var rootId: String
             var blocks: [BlockInformationModelProtocol]
             static func from(event: Anytype_Event.Block.Show) -> Self {
                .init(rootId: event.rootID, blocks: parser.parse(blocks: event.blocks, details: event.details, smartblockType: event.type).blocks)
             }
         }
         
         func createFrom(event: Anytype_Event.Block.Show) -> Event {
             .from(event: event)
         }
         
         func receive(contextId: ContextId) -> AnyPublisher<Event, Never> {
             receiveRawEvent(contextId: contextId).map(Event.from(event:)).eraseToAnyPublisher()
         }
         
         func receiveRawEvent(contextId: ContextId) -> AnyPublisher<Anytype_Event.Block.Show, Never> {
             NotificationCenter.Publisher(center: .default, name: .middlewareEvent, object: nil)
                 .compactMap { $0.object as? Anytype_Event }
                 .filter({$0.contextID == contextId})
                 .map(\.messages)
                 .compactMap { $0.first { $0.value == .blockShow($0.blockShow) }?.blockShow }
                 .eraseToAnyPublisher()
         }

    }
}
