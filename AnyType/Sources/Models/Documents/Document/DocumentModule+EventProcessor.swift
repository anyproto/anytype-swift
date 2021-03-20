//
//  DocumentModule+EventProcessor.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.01.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import Combine
import os
import BlocksModels
import ProtobufMessages

fileprivate typealias Namespace = DocumentModule
fileprivate typealias FileNamespace = Namespace.EventProcessor

private extension Logging.Categories {
    static let eventProcessor: Self = "DocumentModule.EventProcessor"
}

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
        
        func configured(contextId: TopLevel.AliasesMap.BlockId) -> Self {
            self.startListening(contextId: contextId)
            return self
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
            let update: Update = updates.reduce(.general) { (result, value) in .merged(lhs: result, rhs: value) }
            
            guard let container = self.container else {
                let logger = Logging.createLogger(category: .eventProcessor)
                os_log(.debug, log: logger, "Container is nil in event handler. Something went wrong.")
                return
            }

            if update.hasUpdate {
                Builder.blockBuilder.buildTree(container: container.blocksContainer, rootId: container.rootId)
            }

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
    enum Update: Equatable {
        struct Payload: Hashable {
            var addedIds: [BlockId] = []
            var deletedIds: [BlockId] = []
            var updatedIds: [BlockId] = []
            static var empty: Self = .init()
            
            static func merged(lhs: Self, rhs: Self) -> Self {
                .init(addedIds: lhs.addedIds + rhs.addedIds, deletedIds: lhs.deletedIds + rhs.deletedIds, updatedIds: lhs.updatedIds + rhs.updatedIds)
            }
        }
        
        static func merged(lhs: Self, rhs: Self) -> Self {
            switch (lhs, rhs) {
            case (.general, .general): return .general
            case (.update, .general): return lhs
            case (.general, .update): return rhs
            case let (.update(left), .update(right)): return .update(.merged(lhs: left, rhs: right))
            }
        }
        
        func merged(update: Update) -> Self {
            .merged(lhs: self, rhs: update)
        }

        fileprivate static var specialAfterBlockShow: Self = .general
        static var empty: Self = .update(.empty)

        case general
        case update(Payload)

        var hasUpdate: Bool {
            switch self {
            case .empty: return false
            default: return true
            }
        }
    }
}

// MARK: Events Handling
// MARK: Events Handling / InnerEvents
private extension FileNamespace.EventHandler {
    func handleInnerEvent(_ event: Anytype_Event.Message.OneOf_Value) -> Update {
        typealias AttributedTextConverter = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter

        switch event {
        case let .blockAdd(value):
            value.blocks
                .compactMap(self.parser.convert(block:))
                .map(Builder.blockBuilder.informationBuilder.build(information:))
                .map(Builder.blockBuilder.build(information:))
                .forEach { (value) in
                    self.updater?.insert(block: value)
                }
            return .update(.init(addedIds: value.blocks.map(\.id)))
        
        case let .blockDelete(value):
            // Find blocks and remove them from map.
            // And from tree.
            value.blockIds.forEach({ (value) in
                self.updater?.delete(at: value)
            })
            return .update(.init(deletedIds: value.blockIds))
        
        case let .blockSetChildrenIds(value):
            let parentId = value.id
            self.updater?.set(children: value.childrenIds, parent: parentId)
            return .general
            
            /// NOTES:
            /// Our middleware doesn't send current text to us ( ok ), so, we should somehow find it in our model.
            ///
        case let .blockSetText(value):
            let logger = Logging.createLogger(category: .eventProcessor)
            let blockId = value.id

            guard var blockModel = self.container?.blocksContainer.get(by: blockId) else {
                os_log(.debug, log: logger, "We cannot parse style from value: %@ reason: block model not found", String(describing: value))
                return .general
            }

            // TODO: We need introduce Textable protocol for blocks that would support text
            guard case let .text(oldText) = blockModel.information.content else {
                os_log(.debug, log: logger, "We cannot parse style from value: %@ reason: block model doesn't support text", String(describing: value))
                return .general
            }
            let newText = value.hasText ? value.text.value : oldText.attributedText.string
            let newChecked = value.hasChecked ? value.checked.value : oldText.checked

            // obtain current marks as middleware model
            let currentMarks = AttributedTextConverter.asMiddleware(attributedText: oldText.attributedText).marks
            let marks = value.hasMarks ? value.marks.value : currentMarks
            // obtain current block color
            let blockColor = value.hasColor ? value.color.value : oldText.color

            let style = BlocksModelsModule.Parser.Text.ContentType.Converter.asMiddleware(oldText.contentType)
            let textContent: Anytype_Model_Block.Content.Text = .init(text: newText,
                                                                      style: style ?? value.style.value,
                                                                      marks: marks,
                                                                      checked: newChecked,
                                                                      color: blockColor)

            guard let blockContent = self.parser.convert(middlewareContent: .text(textContent)),
                  case var .text(newTextBlockContentType) = blockContent else {
                os_log(.debug, log: logger, "We cannot parse style from value: %@", String(describing: value))
                return .general
            }
            if !value.hasStyle {
                newTextBlockContentType.contentType = oldText.contentType
            }
            blockModel.information.content = .text(newTextBlockContentType)
            
            return .update(.init(updatedIds: [blockId]))

        case let .blockSetBackgroundColor(value):
            let blockId = value.id
            let backgroundColor = value.backgroundColor
            
            self.updater?.update(entry: blockId, update: { (value) in
                var value = value
                value.information.backgroundColor = backgroundColor
            })
            return .update(.empty)
            
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
            return .update(.init(updatedIds: [blockId]))
        
        case let .blockSetDetails(value):
            guard value.hasDetails else {
                return .general
            }
            let detailsId = value.id
            let details = value.details
            let eventsDetails = BlocksModelsModule.Parser.PublicConverters.EventsDetails.convert(event: .init(id: detailsId, details: details))
            let detailsModels = BlocksModelsModule.Parser.Details.Converter.asModel(details: eventsDetails)
            let detailsInformationModel = TopLevel.Builder.detailsBuilder.informationBuilder.build(list: detailsModels)
            
            if let detailsModel = self.container?.detailsContainer.choose(by: detailsId) {
                var model = detailsModel.detailsModel
                var resultDetails = TopLevel.Builder.detailsBuilder.informationBuilder.build(list: detailsModels)
                resultDetails.parentId = detailsId
                model.details = resultDetails
            }
            else {
                var newDetailsModel = TopLevel.Builder.detailsBuilder.build(information: detailsInformationModel)
                newDetailsModel.parent = detailsId
                self.container?.detailsContainer.add(newDetailsModel)
            }
            /// Please, do not delete.
            /// We should discuss how we handle new details.
//            guard let detailsModel = self.container?.detailsContainer.choose(by: detailsId) else {
//                /// We don't have view model, we should create it?
//                /// We should insert empty details.
//                let logger = Logging.createLogger(category: .eventProcessor)
//                os_log(.debug, log: logger, "We cannot find details: %@", String(describing: value))
//                return .general
//            }
            return .update(.empty) // or .general
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
            return .update(.init(updatedIds: [blockId]))
        case let .blockSetBookmark(value):
            
            let blockId = value.id
            let newUpdate = value
            
            self.updater?.update(entry: blockId, update: { (value) in
                var block = value
                switch value.information.content {
                case let .bookmark(value):
                    var value = value
                    
                    if newUpdate.hasURL {
                        value.url = newUpdate.url.value
                    }
                    
                    if newUpdate.hasTitle {
                        value.title = newUpdate.title.value
                    }

                    if newUpdate.hasDescription_p {
                        value.theDescription = newUpdate.description_p.value
                    }

                    if newUpdate.hasImageHash {
                        value.imageHash = newUpdate.imageHash.value
                    }

                    if newUpdate.hasFaviconHash {
                        value.faviconHash = newUpdate.faviconHash.value
                    }

                    if newUpdate.hasType {
                        if let type = BlocksModelsModule.Parser.Bookmark.TypeEnum.Converter.asModel(newUpdate.type.value) {
                            value.type = type
                        }
                    }
                    
                    block.information.content = .bookmark(value)

                default: return
                }
            })
            return .update(.init(updatedIds: [blockId]))
            
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
        
        /// Special case.
        /// After we open document, we would like to receive all blocks of opened page.
        /// For that, we send `blockShow` event to `eventHandler`.
        ///
        case .blockShow: return .specialAfterBlockShow
        
        /// We treat `unknown events` as `empty`, because we won't handle updates for unknown events.
        default: return .empty
        }
    }
}

// MARK: Events Handling / OurEvent
private extension FileNamespace.EventHandler {
    func handleOurEvent(_ event: EventListening.PackOfEvents.OurEvent) -> Update? {
        switch event {
        case let .setFocus(value):
            let blockId = value.payload.blockId
            guard var model = self.container?.blocksContainer.choose(by: blockId) else {
                let logger = Logging.createLogger(category: .eventProcessor)
                os_log(.debug, log: logger, "setFocus. We can't find model by id %@", String(describing: blockId))
                return nil
            }
            model.isFirstResponder = true
            model.focusAt = value.payload.position.flatMap(Focus.Converter.asModel)
            
            /// TODO: We should check that we don't have blocks in updated List.
            /// IF id is in updated list, we should delay of `.didChange` event before all items will be drawn.
            /// For example, it can be done by another case.
            /// This case will capture a completion ( this `didChange()` function ) and call it later.
            model.container?.userSession.didChange()
            
            return .general
        case .setText:
            return nil
            /// TODO:
            /// Remove when you are ready.
//            let blockId = value.payload.blockId
//            guard let model = self.container?.blocksContainer.choose(by: blockId) else {
//                let logger = Logging.createLogger(category: .eventProcessor)
//                os_log(.debug, log: logger, "setText. We can't find model by id %@", String(describing: blockId))
//                return nil
//            }
//
//            guard let attributedText = value.payload.attributedString else {
//                let logger = Logging.createLogger(category: .eventProcessor)
//                os_log(.debug, log: logger, "setText. Text.Payload.attributedString is not allowed to be nil. %@", String(describing: blockId))
//                return nil
//            }
            
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
//            switch model.blockModel.information.content {
//            case let .text(value):
//                var blockModel = model.blockModel
//                var updatedValue = value
//                updatedValue.attributedText = attributedText
//                blockModel.information.content = .text(updatedValue)
//                model.didChange()
//            default: break
//            }
            
            // set text to our model.
//            return .general
        case let .setTextMerge(value):
            let blockId = value.payload.blockId
            guard let model = self.container?.blocksContainer.choose(by: blockId) else {
                let logger = Logging.createLogger(category: .eventProcessor)
                os_log(.debug, log: logger, "setTextMerge. We can't find model by id %@", String(describing: blockId))
                return nil
            }
            
            /// We should call didChange publisher to invoke related setText event (`didChangePublisher()` subscription) in viewModel.
            
            model.didChange()
            
            return .general
        case .setToggled:
            /// TODO: Implement
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
