//
//  DocumentViewModel+New+EventHandler.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 15.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import Combine
import os

private extension Logging.Categories {
    static let eventHandler: Self = "DocumentModule.DocumentViewModel.EventHandler"
}

fileprivate typealias Namespace = DocumentModule

// MARK: Event Listening
extension Namespace.DocumentViewModel {
    class EventHandler: NewEventHandler {
        typealias Event = Anytype_Event.Message.OneOf_Value
        typealias ViewModel = DocumentModule.DocumentViewModel
        typealias BlockId = BlocksModels.Aliases.BlockId
        
        enum Update {
            case updatedKeys([BlockId])
            case general
        }
        
        private var didProcessEventsSubject: PassthroughSubject<Update, Never> = .init()
        var didProcessEventsPublisher: AnyPublisher<Update, Never> = .empty()
        
        
        private typealias Builder = BlocksModels.Block.Builder
        private typealias Information = BlocksModels.Aliases.Information.InformationModel
        private typealias Updater = BlocksModels.Updater
        
        weak var container: BlocksModelsContainerModelProtocol?
        
        private var parser: BlocksModels.Parser = .init()
        private var updater: BlocksModels.Updater?
        
        init() {
            self.setup()
        }
        
        func setup() {
            self.didProcessEventsPublisher = self.didProcessEventsSubject.eraseToAnyPublisher()
        }
                
        func configured(_ container: BlocksModelsContainerModelProtocol) -> Self {
            self.updater = .init(container)
            self.container = container
            return self
        }
                
        func handleOneEvent(_ event: Anytype_Event.Message.OneOf_Value) -> Update {
            switch event {
            case let .blockAdd(value):
                value.blocks
                    .compactMap(self.parser.convert(block:))
                    .map(Information.init(information:))
                    .map({Builder.build(information:$0)})
                    .forEach { (value) in
                        self.updater?.insert(block: value)
                }
                return .general
            
            case let .blockDelete(value):
                // Find blocks and remove them from map.
                // And from tree.
                value.blockIds.forEach({ (value) in
                    self.updater?.delete(at: value)
                })
                return .general
            
            case let .blockSetChildrenIds(value):
                let parentId = value.id
                self.updater?.set(children: value.childrenIds, parent: parentId)
                return .general
                
                /// NOTES:
                /// Our middleware doesn't send current text to us ( ok ), so, we should somehow find it in our model.
                ///
            case let .blockSetText(value):
                guard let style = self.parser.convert(middlewareContent: .text(.init(text: value.text.value, style: value.style.value, marks: value.marks.value, checked: value.checked.value, color: value.color.value))) else {
                    let logger = Logging.createLogger(category: .eventHandler)
                    os_log(.debug, log: logger, "We cannot parse style from value: %@", String(describing: value))
                    return .general
                }
                
                let blockId = value.id
                
                self.updater?.update(entry: blockId, update: { (value) in
                    var value = value
                    switch style {
                    case let .text(newText):
                        switch value.information.content {
                        case let .text(oldText):
                            // For now we only support style
                            var text = oldText
                            text.contentType = newText.contentType
                            value.information.content = .text(text)
                            break
                        default: break
                        }
                    default: break
                    }
                })
                return .updatedKeys([blockId])
                
            default: return .general
            }
        }
        
        private func finalize(_ updates: [Update]) {
            
            // configure one update
            let update: Update = updates.reduce(.general) { (result, value) in
                switch (result, value) {
                case (.general, .general): return .general
                case (.general, .updatedKeys): return value
                case (.updatedKeys, .general): return result
                case let (.updatedKeys(lhs), .updatedKeys(rhs)): return .updatedKeys(lhs + rhs)
                }
            }
            
            guard let container = self.container else {
                let logger = Logging.createLogger(category: .eventHandler)
                os_log(.debug, log: logger, "Container is nil in event handler. Something went wrong.")
                return
            }
            
            Builder.buildTree(container: container)
            // Notify about updates if needed.
            self.didProcessEventsSubject.send(update)
        }
        
        func handle(events: [Anytype_Event.Message.OneOf_Value]) {
            self.finalize(events.compactMap(self.handleOneEvent(_:)))
        }
    }

}
