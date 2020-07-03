//
//  BlockActionService+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 14.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

fileprivate typealias Namespace = ServiceLayerModule

protocol NewModel_BlockActionsServiceProtocolOpen {
    associatedtype Success
    func action(contextID: String, blockID: String) -> AnyPublisher<Success, Error>
}

protocol NewModel_BlockActionsServiceProtocolClose {
    func action(contextID: String, blockID: String) -> AnyPublisher<Never, Error>
}

protocol NewModel_BlockActionsServiceProtocolAdd {
    associatedtype Success
    func action(contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error>
}

protocol NewModel_BlockActionsServiceProtocolSplit {
    associatedtype Success
    func action(contextID: String, blockID: String, cursorPosition: Int32, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error>
    func action(contextID: String, blockID: String, range: NSRange, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error>
}

protocol NewModel_BlockActionsServiceProtocolReplace {
    associatedtype Success
    func action(contextID: String, blockID: String, block: Anytype_Model_Block) -> AnyPublisher<Success, Error>
}

protocol NewModel_BlockActionsServiceProtocolDelete {
    associatedtype Success
    func action(contextID: String, blockIds: [String]) -> AnyPublisher<Success, Error>
}

protocol NewModel_BlockActionsServiceProtocolMerge {
    associatedtype Success
    func action(contextID: String, firstBlockID: String, secondBlockID: String) -> AnyPublisher<Success, Error>
}

protocol NewModel_BlockListActionsServiceProtocolDuplicate {
    associatedtype Success
    func action(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error>
}

protocol NewModel_BlockEventListener {
    associatedtype Event
    func receive(contextId: String) -> AnyPublisher<Event, Never>
}

protocol NewModel_BlockActionsServiceProtocol {
    associatedtype Open: NewModel_BlockActionsServiceProtocolOpen
    associatedtype Close: NewModel_BlockActionsServiceProtocolClose
    associatedtype Add: NewModel_BlockActionsServiceProtocolAdd
    associatedtype Split: NewModel_BlockActionsServiceProtocolSplit
    associatedtype Replace: NewModel_BlockActionsServiceProtocolReplace
    associatedtype Delete: NewModel_BlockActionsServiceProtocolDelete
    associatedtype Merge: NewModel_BlockActionsServiceProtocolMerge
    associatedtype Duplicate: NewModel_BlockListActionsServiceProtocolDuplicate
    associatedtype EventListener: NewModel_BlockEventListener
    
    var open: Open {get}
    var close: Close {get}
    var add: Add {get}
    var split: Split {get}
    var replace: Replace {get}
    var delete: Delete {get}
    var merge: Merge {get}
    var duplicate: Duplicate {get}
    var eventListener: EventListener {get}
}

extension Namespace {
    class BlockActionsService: NewModel_BlockActionsServiceProtocol {
        typealias ContextId = String
        
        var open: Open = .init() // SmartBlock only for now?
        var close: Close = .init() // SmartBlock only for now?
        var add: Add = .init()
        var split: Split = .init() // Remove Split and Merge to TextBlocks only.
        var replace: Replace = .init()
        var delete: Delete = .init()
        var merge: Merge = .init() // Remove Split and Merge to TextBlocks only.
        var duplicate: Duplicate = .init() // BlockList?
        var eventListener: EventListener = .init()
    }
}

// MARK: Actions
extension Namespace.BlockActionsService {
    typealias Success = ServiceLayerModule.Success
    
    // MARK: Open / Close
    struct Open: NewModel_BlockActionsServiceProtocolOpen {
        func action(contextID: String, blockID: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Open.Service.invoke(contextID: contextID, blockID: blockID).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Close: NewModel_BlockActionsServiceProtocolClose {
        func action(contextID: String, blockID: String) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.Block.Close.Service.invoke(contextID: contextID, blockID: blockID).ignoreOutput().subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: Create (OR Add) / Replace / Unlink ( OR Delete )
    struct Add: NewModel_BlockActionsServiceProtocolAdd {
        func action(contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Create.Service.invoke(contextID: contextID, targetID: targetID, block: block, position: position)
                .map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Split: NewModel_BlockActionsServiceProtocolSplit {
        func action(contextID: String, blockID: String, cursorPosition: Int32, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Split.Service.invoke(contextID: contextID, blockID: blockID, range: .init(from: cursorPosition, to: cursorPosition), style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
        func action(contextID: String, blockID: String, range: NSRange, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<ServiceLayerModule.Success, Error> {
            let middlewareRange = BlocksModels.Parser.Text.AttributedText.RangeConverter.asMiddleware(range)
            return Anytype_Rpc.Block.Split.Service.invoke(contextID: contextID, blockID: blockID, range: middlewareRange, style: style).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    struct Replace: NewModel_BlockActionsServiceProtocolReplace {
        func action(contextID: String, blockID: String, block: Anytype_Model_Block) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Replace.Service.invoke(contextID: contextID, blockID: blockID, block: block).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Delete: NewModel_BlockActionsServiceProtocolDelete {
        func action(contextID: String, blockIds: [String]) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextID, blockIds: blockIds).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    // MARK: Merge
    struct Merge: NewModel_BlockActionsServiceProtocolMerge {
        func action(contextID: String, firstBlockID: String, secondBlockID: String) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Merge.Service.invoke(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID)
                .map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global()).eraseToAnyPublisher()
        }
    }
    
    // MARK: Duplicate
    // Actually, should be used for BlockList
    struct Duplicate: NewModel_BlockListActionsServiceProtocolDuplicate {
        func action(contextID: String, targetID: String, blockIds: [String], position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.BlockList.Duplicate.Service.invoke(contextID: contextID, targetID: targetID, blockIds: blockIds, position: position).map(\.event).map(Success.init(_:)).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
}

extension Namespace.BlockActionsService {
    // MARK: Events Processing
    // MARK: It is new Listener, so, you should replace old listener.
    struct EventListener: NewModel_BlockEventListener {
        private static let parser: BlocksModels.Parser = .init()
        
         struct Event {
             var rootId: String
             var blocks: [BlocksModelsInformationModelProtocol]
             static func from(event: Anytype_Event.Block.Show) -> Self {
                 .init(rootId: event.rootID, blocks: parser.parse(blocks: event.blocks, details: event.details, smartblockType: event.type))
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
