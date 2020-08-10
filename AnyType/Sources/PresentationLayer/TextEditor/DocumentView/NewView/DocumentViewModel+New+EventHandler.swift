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
import BlocksModels

private extension Logging.Categories {
    static let eventProcessor: Self = "DocumentModule.DocumentViewModel.EventProcessor"
}

fileprivate typealias Namespace = DocumentModule.DocumentViewModel
fileprivate typealias FileNamespace = Namespace.EventProcessor

// MARK: Event Processor
extension Namespace {
    /// This class encapsulates all logic for handling events.
    ///
    /// Setup for this class:
    ///
    /// ```
    /// let processor: EventProcessor = .init()
    /// let container: BlocksModelsContainerModelProtocol = /// get container
    /// processor.configured(container)
    /// ```
    ///
    /// If you want to listen events, you could use publisher:
    ///
    /// ```
    /// processor.didProcessEventsPublisher // do stuff
    /// ```
    ///
    /// If you want to handle events directly:
    ///
    /// ```
    /// processor.handle(events:)
    /// ```
    ///
    class EventProcessor {
        private var eventHandler: EventHandler
        private var eventPublisher: EventListening.NotificationEventListener<EventHandler>?
        init() {
            self.eventHandler = .init()
            self.eventPublisher = .init(handler: self.eventHandler)
        }
        
        private func startListening(contextId: String) {
            self.eventPublisher?.receive(contextId: contextId)
        }
        
        // MARK: EventHandler interface
        var didProcessEventsPublisher: AnyPublisher<EventHandler.Update, Never> { self.eventHandler.didProcessEventsPublisher }
        func configured(_ container: TopLevelContainerModelProtocol) -> Self {
            _ = self.eventHandler.configured(container)
            if let rootId = container.rootId {
                self.startListening(contextId: rootId)
            }
            else {
                let logger = Logging.createLogger(category: .eventProcessor)
                os_log(.debug, log: logger, "We can't start listening rootId (%@) of container: (%@)", String(describing: container.rootId), String(describing: container))
            }
            return self
        }
        func handle(events: EventHandler.EventsContainer) {
            self.eventHandler.handle(events: events)
        }
    }
}

// MARK: Block Show
extension Namespace.EventProcessor {
    func handleBlockShow(events: EventHandler.EventsContainer) -> [BlocksModelsModule.Parser.PageEvent] {
        self.eventHandler.handleBlockShow(events: events)
    }
}

// MARK: Event Listening
extension FileNamespace {
    class EventHandler: NewEventHandler {
        typealias EventsContainer = EventListening.PackOfEvents
        typealias BlockId = TopLevel.AliasesMap.BlockId
                
        private var didProcessEventsSubject: PassthroughSubject<Update, Never> = .init()
        var didProcessEventsPublisher: AnyPublisher<Update, Never> = .empty()
        
        
        private typealias Builder = TopLevel.Builder
        private typealias Updater = TopLevel.AliasesMap.BlockTools.Updater
        private typealias Container = TopLevelContainerModelProtocol
        
        private weak var container: Container?
        
        private var parser: BlocksModelsModule.Parser = .init()
        private var updater: Updater?
        
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
                let logger = Logging.createLogger(category: .eventProcessor)
                os_log(.debug, log: logger, "Container is nil in event handler. Something went wrong.")
                return
            }
            
            Builder.blockBuilder.buildTree(container: container.blocksContainer, rootId: container.rootId)
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

// MARK: Block Show
extension FileNamespace.EventHandler {
    func handleBlockShow(event: Anytype_Event.Message.OneOf_Value) -> BlocksModelsModule.Parser.PageEvent {
        switch event {
        case let .blockShow(value): return self.parser.parse(blocks: value.blocks, details: value.details, smartblockType: value.type)
        default: return .empty()
        }
    }
    func handleBlockShow(events: EventsContainer) -> [BlocksModelsModule.Parser.PageEvent] {
        events.events.compactMap(\.value).compactMap(self.handleBlockShow(event:))
    }
}

// MARK: Setup
private extension FileNamespace.EventHandler {
    func setup() {
        self.didProcessEventsPublisher = self.didProcessEventsSubject.eraseToAnyPublisher()
    }
}

// MARK: Configurations
private extension FileNamespace.EventHandler {
    func configured(_ container: TopLevelContainerModelProtocol) -> Self {
        self.updater = .init(container.blocksContainer)
        self.container = container
        return self
    }
}

// MARK: Update
extension FileNamespace.EventHandler {
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
private extension FileNamespace.EventHandler {
    func handleInnerEvent(_ event: Anytype_Event.Message.OneOf_Value) -> Update {
        switch event {
            
        case let .blockAdd(value):
            value.blocks
                .compactMap(self.parser.convert(block:))
                .map(Builder.blockBuilder.informationBuilder.build(information:))
                .map(Builder.blockBuilder.build(information:))
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
                let logger = Logging.createLogger(category: .eventProcessor)
                os_log(.debug, log: logger, "We cannot parse style from value: %@", String(describing: value))
                return .general
            }
            
            let blockId = value.id
            
            let newUpdate = value
            
            /// Add Split and Merge blocks text processing.
            self.updater?.update(entry: blockId, update: { (value) in
                var value = value
                switch style {
                case let .text(newText):
                    switch value.information.content {
                    case let .text(oldText):
                        // For now we only support style
                        var text = oldText
                        if newUpdate.hasText {
                            text.attributedText = newText.attributedText
                        }
                        if newUpdate.hasStyle {
                            text.contentType = newText.contentType
                        }
                        value.information.content = .text(text)
                        break
                    default: break
                    }
                default: break
                }
            })
            return .update(.init(deletedIds: [], updatedIds: [blockId]))
        
        case let .blockSetAlign(value):
            let blockId = value.id
            let alignment = value.align
            guard let modelAlignment = BlocksModelsModule.Parser.Common.Alignment.Converter.asModel(alignment) else {
                let logger = Logging.createLogger(category: .eventProcessor)
                os_log(.debug, log: logger, "We cannot parse alignment: %@", String(describing: value))
                return .general
            }
            
            self.updater?.update(entry: blockId, update: { (value) in
                var value = value
                value.information.alignment = modelAlignment
            })
            return .update(.init(deletedIds: [], updatedIds: [blockId]))
        
        case let .blockSetDetails(value):
            guard value.hasDetails else {
                return .general
            }
            let detailsId = value.id
            guard let detailsModel = self.container?.detailsContainer.choose(by: detailsId) else {
                /// We don't have view model, we should create it?
                let logger = Logging.createLogger(category: .eventProcessor)
                os_log(.debug, log: logger, "We cannot parse details: %@", String(describing: value))
                return .general
            }
            let details = value.details
            let eventsDetails = BlocksModelsModule.Parser.PublicConverters.EventsDetails.convert(event: .init(id: detailsId, details: details))
            let detailsModels = BlocksModelsModule.Parser.Details.Converter.asModel(details: eventsDetails)
            var model = detailsModel.detailsModel
            model.details = TopLevel.Builder.detailsBuilder.informationBuilder.build(list: detailsModels)
            return .general
        case let .blockSetFile(value):
            guard value.hasState else {
                return .general
            }
            
            let blockId = value.id
            let newUpdate = value
            self.updater?.update(entry: blockId, update: { (value) in
                var block = value
                switch value.information.content {
                case let .file(value):
                    var value = value

                    if newUpdate.hasType {
                        if let contentType = BlocksModelsModule.Parser.File.ContentType.Converter.asModel(newUpdate.type.value) {
                            value.contentType = contentType
                        }
                    }

                    if newUpdate.hasState {
                        if let state = BlocksModelsModule.Parser.File.State.Converter.asModel(newUpdate.state.value) {
                            value.state = state
                        }
                    }
                    
                    if newUpdate.hasName {
                        value.metadata.name = newUpdate.name.value
                    }
                    
                    if newUpdate.hasHash {
                        value.metadata.hash = newUpdate.hash.value
                    }
                    
                    if newUpdate.hasMime {
                        value.metadata.mime = newUpdate.mime.value
                    }
                    
                    if newUpdate.hasSize {
                        value.metadata.size = newUpdate.size.value
                    }
                    
                    block.information.content = .file(value)
                default: return
                }
            })
            return .update(.init(deletedIds: [], updatedIds: [blockId]))
        case let .blockSetDiv(value):
            guard value.hasStyle else {
                return .general
            }
            
            let blockId = value.id
            let newUpdate = value
            
            self.updater?.update(entry: blockId, update: { (value) in
                var block = value
                switch value.information.content {
                case let .divider(value):
                    var value = value
                                        
                    if let style = BlocksModelsModule.Parser.Other.Divider.Style.Converter.asModel(newUpdate.style.value) {
                        value.style = style
                    }
                    
                    block.information.content = .divider(value)
                    
                default: return
                }
            })
            
            return .general
            
        default: return .general
        }
    }
}

// MARK: Events Handling / OurEvent
private extension FileNamespace.EventHandler {
    func handleOurEvent(_ event: EventListening.PackOfEvents.OurEvent) -> Update? {
        switch event {
        case let .setFocus(value):
            let blockId = value.payload.blockId
            guard var focusedModel = self.container?.blocksContainer.choose(by: blockId) else {
                let logger = Logging.createLogger(category: .eventProcessor)
                os_log(.debug, log: logger, "We can't find focused model by id %@", String(describing: blockId))
                return nil
            }
            focusedModel.isFirstResponder = true
            focusedModel.focusAt = value.payload.position.flatMap(Focus.Converter.asModel)
            
            /// TODO: We should check that we don't have blocks in updated List.
            /// IF id is in updated list, we should delay of `.didChange` event before all items will be drawn.
            /// For example, it can be done by another case.
            /// This case will capture a completion ( this `didChange()` function ) and call it later.
            focusedModel.container?.userSession.didChange()
            
            return .general
        case let .setText(value):
            return nil
            let blockId = value.payload.blockId
            guard let focusedModel = self.container?.blocksContainer.choose(by: blockId) else {
                let logger = Logging.createLogger(category: .eventProcessor)
                os_log(.debug, log: logger, "We can't find focused model by id %@", String(describing: blockId))
                return nil
            }
            
            guard let attributedText = value.payload.attributedString else {
                let logger = Logging.createLogger(category: .eventProcessor)
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
private extension FileNamespace.EventHandler {
    enum Focus {}
}

private extension FileNamespace.EventHandler.Focus {
    enum Converter {
        typealias Model = TopLevel.AliasesMap.FocusPosition
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
