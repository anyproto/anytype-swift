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
        typealias EventsContainer = EventListening.PackOfEvents
        typealias ViewModel = DocumentModule.DocumentViewModel
        typealias BlockId = BlocksModels.Aliases.BlockId
                
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
                                        
        private func finalize(_ updates: [Update]) {
            
            // configure one update
            let update: Update = updates.reduce(.general) { (result, value) in
                switch (result, value) {
                case (.general, .general): return .general
                case (.general, .update): return value
                case (.update, .general): return result
                case let (.update(lhs), .update(rhs)): return .update(.init(deletedIds: lhs.deletedIds + rhs.deletedIds, updatedIds: lhs.updatedIds + rhs.updatedIds))
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
        
        func handle(events: EventsContainer) {
            let innerUpdates = events.events.compactMap(\.value).compactMap(self.handleInnerEvent(_:))
            let ourUpdates = events.ourEvents.compactMap(self.handleOurEvent(_:))
            self.finalize(innerUpdates + ourUpdates)
        }
    }

}

// MARK: Setup
private extension Namespace.DocumentViewModel.EventHandler {
    func setup() {
        self.didProcessEventsPublisher = self.didProcessEventsSubject.eraseToAnyPublisher()
    }
}

// MARK: Configurations
extension Namespace.DocumentViewModel.EventHandler {
    func configured(_ container: BlocksModelsContainerModelProtocol) -> Self {
        self.updater = .init(container)
        self.container = container
        return self
    }
}

// MARK: Update
extension Namespace.DocumentViewModel.EventHandler {
    enum Update {
        struct Payload {
            var deletedIds: [BlockId] = []
            var updatedIds: [BlockId] = []
        }
        case general
        case update(Payload)
    }
}

// MARK: Events Handling
// MARK: Events Handling / InnerEvents
private extension Namespace.DocumentViewModel.EventHandler {
    func handleInnerEvent(_ event: Anytype_Event.Message.OneOf_Value) -> Update {
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
            return .update(.init(deletedIds: value.blockIds, updatedIds: []))
        
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
            return .update(.init(deletedIds: [], updatedIds: [blockId]))
            
        default: return .general
        }
    }
}

// MARK: Events Handling / OurEvent
private extension Namespace.DocumentViewModel.EventHandler {
    func handleOurEvent(_ event: EventListening.PackOfEvents.OurEvent) -> Update? {
        switch event {
        case let .setFocus(value):
            let blockId = value.payload.blockId
            guard var focusedModel = self.container?.choose(by: blockId) else {
                let logger = Logging.createLogger(category: .eventHandler)
                os_log(.debug, log: logger, "We can't find focused model by id %@", String(describing: blockId))
                return nil
            }
            focusedModel.isFirstResponder = true
            focusedModel.focusAt = value.payload.position.flatMap(Focus.Converter.asModel)
            focusedModel.container?.userSession.didChange()
            
            return .general
        case let .setText(value):
            let blockId = value.payload.blockId
            guard let focusedModel = self.container?.choose(by: blockId) else {
                let logger = Logging.createLogger(category: .eventHandler)
                os_log(.debug, log: logger, "We can't find focused model by id %@", String(describing: blockId))
                return nil
            }
            
            guard let attributedText = value.payload.attributedString else {
                let logger = Logging.createLogger(category: .eventHandler)
                os_log(.debug, log: logger, "Text.Payload.attributedString is not allowed to be nil. %@", String(describing: blockId))
                return nil
            }
            
//            self.updater?.update(entry: focusedModel.blockModel.information.id, update: { (value) in
//                switch value.information.content {
//                case let .text(oldValue):
//                    var newValue = oldValue
//                    newValue.attributedText = attributedText
//                    var value = value
//                    value.information.content = .text(newValue)
//                default: return
//                }
//            })
            switch focusedModel.blockModel.information.content {
            case let .text(value):
                var blockModel = focusedModel.blockModel
                var updatedValue = value
                updatedValue.attributedText = attributedText
                blockModel.information.content = .text(updatedValue)
                focusedModel.didChange()
            default: break
            }
            
            // set text to our model.
            return .general
        }
    }
}

// MARK: Converters
private extension Namespace.DocumentViewModel.EventHandler {
    enum Focus {}
}

private extension Namespace.DocumentViewModel.EventHandler.Focus {
    enum Converter {
        typealias Model = BlocksModels.Aliases.FocusPosition
        typealias EventModel = EventListening.PackOfEvents.OurEvent.Focus.Payload.Position
        static func asModel(_ value: EventModel) -> Model? {
            switch value {
            case .unknown: return .unknown
            case .beginning: return .beginning
            case .end: return .end
            case let .at(value): return .at(value)
            }
        }
        
        static func asEventModel(_ value: Model) -> EventModel? {
            switch value {
            case .unknown: return .unknown
            case .beginning: return .beginning
            case .end: return .end
            case let .at(value): return .at(value)
            }
        }
    }
}
