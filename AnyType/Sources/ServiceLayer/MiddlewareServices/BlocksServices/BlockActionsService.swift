//
//  BlockActionsService.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 27.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine

protocol BlockActionsServiceProtocolOpen {
    func action(contextID: String, blockID: String, breadcrumbsIds: [String]) -> AnyPublisher<Never, Error>
}

protocol BlockActionsServiceProtocolClose {
    func action(contextID: String, blockID: String) -> AnyPublisher<Never, Error>
}

protocol BlockActionsServiceProtocolAdd {
    associatedtype Success
    func action(contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error>
}

protocol BlockActionsServiceProtocolSplit {
    associatedtype Success
    func action(contextID: String, blockID: String, cursorPosition: Int32, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error>
}

protocol BlockActionsServiceProtocolReplace {
    associatedtype Success
    func action(contextID: String, blockID: String, block: Anytype_Model_Block) -> AnyPublisher<Success, Error>
}

protocol BlockActionsServiceProtocolDelete {
    func action(contextID: String, blockIds: [String]) -> AnyPublisher<Never, Error>
}

protocol BlockActionsServiceProtocolMerge {
    func action(contextID: String, firstBlockID: String, secondBlockID: String) -> AnyPublisher<Never, Error>
}

protocol BlockEventListener {
    associatedtype Event
    func receive(contextId: String) -> AnyPublisher<Event, Never>
}

protocol BlockActionsServiceProtocol {
    associatedtype Open: BlockActionsServiceProtocolOpen
    associatedtype Close: BlockActionsServiceProtocolClose
    associatedtype Add: BlockActionsServiceProtocolAdd
    associatedtype Split: BlockActionsServiceProtocolSplit
    associatedtype Replace: BlockActionsServiceProtocolReplace
    associatedtype Delete: BlockActionsServiceProtocolDelete
    associatedtype Merge: BlockActionsServiceProtocolMerge
    associatedtype EventListener: BlockEventListener
    
    var open: Open {get}
    var close: Close {get}
    var add: Add {get}
    var split: Split {get}
    var replace: Replace {get}
    var delete: Delete {get}
    var merge: Merge {get}
    var eventListener: EventListener {get}
}

class BlockActionsService: BlockActionsServiceProtocol {
    typealias ContextId = String
    var open: Open = .init()
    var close: Close = .init()
    var add: Add = .init()
    var split: Split = .init()
    var replace: Replace = .init()
    var delete: Delete = .init()
    var merge: Merge = .init()
    var eventListener: EventListener = .init()
    
    // MARK: Open / Close
    struct Open: BlockActionsServiceProtocolOpen {
        func action(contextID: String, blockID: String, breadcrumbsIds: [String] = []) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.Block.Open.Service.invoke(contextID: contextID, blockID: blockID, breadcrumbsIds: breadcrumbsIds).ignoreOutput().subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Close: BlockActionsServiceProtocolClose {
        func action(contextID: String, blockID: String) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.Block.Close.Service.invoke(contextID: contextID, blockID: blockID).ignoreOutput().subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: Create (OR Add) / Replace / Unlink ( OR Delete )
    struct Add: BlockActionsServiceProtocolAdd {
        struct Success {
            var blockID: String
        }
        func action(contextID: String, targetID: String, block: Anytype_Model_Block, position: Anytype_Model_Block.Position) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Create.Service.invoke(contextID: contextID, targetID: targetID, block: block, position: position).map({Success.init(blockID: $0.blockID)}).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Split: BlockActionsServiceProtocolSplit {
        struct Success {
            var blockID: String
        }
        func action(contextID: String, blockID: String, cursorPosition: Int32, style: Anytype_Model_Block.Content.Text.Style) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Split.Service.invoke(contextID: contextID, blockID: blockID, cursorPosition: cursorPosition, style: style).map({Success.init(blockID: $0.blockID)}).subscribe(on: DispatchQueue.global())
            .eraseToAnyPublisher()
        }
    }
    
    struct Replace: BlockActionsServiceProtocolReplace {
        struct Success {
            var blockID: String
        }
        func action(contextID: String, blockID: String, block: Anytype_Model_Block) -> AnyPublisher<Success, Error> {
            Anytype_Rpc.Block.Replace.Service.invoke(contextID: contextID, blockID: blockID, block: block).map({Success.init(blockID: $0.blockID)}).subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    struct Delete: BlockActionsServiceProtocolDelete {
        func action(contextID: String, blockIds: [String]) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.Block.Unlink.Service.invoke(contextID: contextID, blockIds: blockIds).ignoreOutput().subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
    
    // MARK: Merge
    struct Merge: BlockActionsServiceProtocolMerge {
        func action(contextID: String, firstBlockID: String, secondBlockID: String) -> AnyPublisher<Never, Error> {
            Anytype_Rpc.Block.Merge.Service.invoke(contextID: contextID, firstBlockID: firstBlockID, secondBlockID: secondBlockID)
                .ignoreOutput()
                .subscribe(on: DispatchQueue.global())
                .eraseToAnyPublisher()
        }
    }
}

extension BlockActionsService {
    // MARK: Events Processing
    struct EventListener: BlockEventListener {
        private static let parser = BlockModels.Parser()
       
        struct Event {
            var rootId: String
            var blocks: [MiddlewareBlockInformationModel]
            static func from(event: Anytype_Event.Block.Show) -> Self {
                .init(rootId: event.rootID, blocks: parser.parse(blocks: event.blocks))
            }
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
