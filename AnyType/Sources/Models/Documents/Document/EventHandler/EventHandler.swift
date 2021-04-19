import Foundation
import Combine
import os
import BlocksModels
import ProtobufMessages

class EventHandler: EventHandlerProtocol {
    private var didProcessEventsSubject: PassthroughSubject<EventHandlerUpdate, Never> = .init()
    var didProcessEventsPublisher: AnyPublisher<EventHandlerUpdate, Never> = .empty()
    
    private typealias Updater = Block.Tools.Updater
    
    private weak var container: ContainerModel?
    
    var parser: BlocksModelsParser = .init()
    private var updater: Updater?
    private let blockValidator = BlockValidator(restrictionsFactory: BlockRestrictionsFactory())
    
    init() {
        self.didProcessEventsPublisher = self.didProcessEventsSubject.eraseToAnyPublisher()
    }
                                    
    private func finalize(_ updates: [EventHandlerUpdate]) {
        
        // configure one update
        let update: EventHandlerUpdate = updates.reduce(.general) { (result, value) in .merged(lhs: result, rhs: value) }
        
        guard let container = self.container else {
            assertionFailure("Container is nil in event handler. Something went wrong.")
            return
        }

        if update.hasUpdate {
            TopLevelBuilderImpl.blockBuilder.buildTree(container: container.blocksContainer, rootId: container.rootId)
        }

        // Notify about updates if needed.
        self.didProcessEventsSubject.send(update)
    }
    
    func handle(events: EventListening.PackOfEvents) {
        let innerUpdates = events.events.compactMap(\.value).compactMap(self.handleInnerEvent(_:))
        let ourUpdates = events.ourEvents.compactMap(self.handleOurEvent(_:))
        self.finalize(innerUpdates + ourUpdates)
    }

    // MARK: Configurations
    func configured(_ container: ContainerModel) -> Self {
        self.updater = .init(container)
        self.container = container
        return self
    }

    // MARK: Events Handling / InnerEvents
    func handleInnerEvent(_ event: Anytype_Event.Message.OneOf_Value) -> EventHandlerUpdate {
        typealias AttributedTextConverter = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter

        switch event {
        case let .blockAdd(value):
            value.blocks
                .compactMap(self.parser.convert(block:))
                .map(TopLevelBuilderImpl.blockBuilder.informationBuilder.build(information:))
                .map(TopLevelBuilderImpl.blockBuilder.createBlockModel)
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
            let blockId = value.id

            guard var blockModel = self.container?.blocksContainer.get(by: blockId) else {
                assertionFailure("We cannot parse style from value: \(value)\n reason: block model not found")
                return .general
            }

            // TODO: We need introduce Textable protocol for blocks that would support text
            guard case let .text(oldText) = blockModel.information.content else {
                assertionFailure("We cannot parse style from value: \(value)\n reason: block model doesn't support text")
                return .general
            }
            let newText = value.hasText ? value.text.value : oldText.attributedText.string
            let newChecked = value.hasChecked ? value.checked.value : oldText.checked

            // Apply marks only if we haven't received text and marks.
            var marks = value.marks.value
            if !value.hasText, !value.hasMarks {
                // obtain current marks as middleware model
                marks = AttributedTextConverter.asMiddleware(attributedText: oldText.attributedText).marks
            }

            // obtain current block color
            let blockColor = value.hasColor ? value.color.value : oldText.color
            let style: Anytype_Model_Block.Content.Text.Style
            if value.hasStyle {
                style = value.style.value
            } else {
                style = BlocksModelsParserTextContentTypeConverter.asMiddleware(oldText.contentType)
            }
            let textContent: Anytype_Model_Block.Content.Text = .init(text: newText,
                                                                      style: style,
                                                                      marks: marks,
                                                                      checked: newChecked,
                                                                      color: blockColor)

            guard let blockContent = self.parser.convert(middlewareContent: .text(textContent)),
                  case var .text(newTextBlockContentType) = blockContent else {
                assertionFailure("We cannot parse style from value: \(value)")
                return .general
            }
            if !value.hasStyle {
                newTextBlockContentType.contentType = oldText.contentType
            }
            newTextBlockContentType.number = oldText.number
            blockModel.information.content = .text(newTextBlockContentType)
            self.blockValidator.validate(information: &blockModel.information)
            
            return .update(.init(updatedIds: [blockId]))

        case let .blockSetBackgroundColor(value):
            let blockId = value.id
            let backgroundColor = value.backgroundColor
            
            self.updater?.update(entry: blockId, update: { (value) in
                var value = value
                value.information.backgroundColor = backgroundColor
            })
            return .update(.init(updatedIds: [blockId]))
            
        case let .blockSetAlign(value):
            let blockId = value.id
            let alignment = value.align
            guard let modelAlignment = BlocksModelsParserCommonAlignmentConverter.asModel(alignment) else {
                assertionFailure("We cannot parse alignment: \(value)")
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
            let eventsDetails = BlocksModelsParser.PublicConverters.EventsDetails.convert(event: .init(id: detailsId, details: details))
            let detailsModels = BlocksModelsParser.Details.Converter.asModel(details: eventsDetails)
            let detailsInformationModel = TopLevelBuilderImpl.detailsBuilder.informationBuilder.build(list: detailsModels)
            
            if let detailsModel = self.container?.detailsContainer.choose(by: detailsId) {
                var model = detailsModel.detailsModel
                var resultDetails = TopLevelBuilderImpl.detailsBuilder.informationBuilder.build(list: detailsModels)
                resultDetails.parentId = detailsId
                model.details = resultDetails
            }
            else {
                var newDetailsModel = TopLevelBuilderImpl.detailsBuilder.build(information: detailsInformationModel)
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
                        if let contentType = BlocksModelsParserFileContentTypeConverter.asModel(newUpdate.type.value) {
                            value.contentType = contentType
                        }
                    }

                    if newUpdate.hasState {
                        if let state = BlocksModelsParserFileStateConverter.asModel(newUpdate.state.value) {
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
                        if let type = BlocksModelsParserBookmarkTypeEnumConverter.asModel(newUpdate.type.value) {
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
                                        
                    if let style = BlocksModelsParserOtherDividerStyleConverter.asModel(newUpdate.style.value) {
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

    // MARK: Events Handling / OurEvent
    func handleOurEvent(_ event: EventListening.OurEvent) -> EventHandlerUpdate? {
        switch event {
        case let .setFocus(value):
            let blockId = value.payload.blockId
            guard var model = self.container?.blocksContainer.choose(by: blockId) else {
                assertionFailure("setFocus. We can't find model by id \(blockId)")
                return nil
            }
            model.isFirstResponder = true
            model.focusAt = value.payload.position.flatMap(EventHandlerFocusConverter.asModel)
            
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
                assertionFailure("setTextMerge. We can't find model by id \(blockId)")
                return nil
            }
            
            /// We should call didChange publisher to invoke related setText event (`didChangePublisher()` subscription) in viewModel.
            
            model.didChange()
            
            return .general
        case let .setToggled(payload):
            guard let container = self.container,
                  let block = container.blocksContainer.choose(by: payload.payload.blockId) else {
                return .empty
            }
            if !block.isToggled {
                let flattener = BaseFlattener.self
                let deletedIds = flattener.flattenIds(root: block,
                                                      in: container,
                                                      options: .init(shouldCheckIsRootToggleOpened: false,
                                                                     shouldSetNumbers: false))
                return .update(.init(deletedIds: deletedIds))
            } else {
                return .update(.init(openedToggleId: payload.payload.blockId))
            }

        }
    }
}
