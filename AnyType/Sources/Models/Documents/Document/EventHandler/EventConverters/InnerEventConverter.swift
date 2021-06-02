import ProtobufMessages
import BlocksModels

final class InnerEventConverter {
    private let updater: BlockUpdater
    private weak var container: ContainerModelProtocol?
    
    private let blockValidator = BlockValidator(restrictionsFactory: BlockRestrictionsFactory())
    
    init(updater: BlockUpdater, container: ContainerModelProtocol?) {
        self.updater = updater
        self.container = container
    }
    
    func convert(_ event: Anytype_Event.Message.OneOf_Value) -> EventHandlerUpdate? {
        typealias AttributedTextConverter = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter

        switch event {
        case let .blockSetFields(fields):
            updater.update(entry: fields.id) { block in
                var block = block

                block.information.fields = fields.fields.toFieldTypeMap()
                block.didChange()
            }
            return nil
        case let .blockAdd(value):
            value.blocks
                .compactMap(BlockModelsInformationConverter.convert(block:))
                .map(TopLevelBlockBuilder.shared.informationBuilder.build(information:))
                .map(TopLevelBlockBuilder.shared.createBlockModel)
                .forEach { (value) in
                    updater.insert(block: value)
                }
            // Because blockAdd message will always come together with blockSetChildrenIds
            // and it is easier to create update from those message
            return nil
        
        case let .blockDelete(value):
            value.blockIds.forEach({ (value) in
                updater.delete(at: value)
            })
            // Because blockDelete message will always come together with blockSetChildrenIds
            // and it is easier to create update from those message
            return nil
        
        case let .blockSetChildrenIds(value):
            updater.set(children: value.childrenIds, parent: value.id)
            return .general
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

            let style: Anytype_Model_Block.Content.Text.Style
            if value.hasStyle {
                style = value.style.value
            } else {
                style = BlocksModelsParserTextContentTypeConverter.asMiddleware(oldText.contentType)
            }

            // Apply marks only if we haven't received text and marks.
            var marks = value.marks.value
            if !value.hasText, !value.hasMarks {
                // obtain current marks as middleware model
                marks = AttributedTextConverter.asMiddleware(attributedText: oldText.attributedText).marks
            }

            // Workaroung: Some font could set bold style to attributed string
            // So if header or title style has font that apply bold we remove it
            // We need it if change style from subheading to text
            let oldStyle = BlocksModelsParserTextContentTypeConverter.asMiddleware(oldText.contentType)
            if [.header1, .header2, .header3, .header4, .title].contains(oldStyle) {
                marks.marks.removeAll { mark in
                    mark.type == .bold
                }
            }

            // obtain current block color
            let blockColor = value.hasColor ? value.color.value : oldText.color

            let textContent: Anytype_Model_Block.Content.Text = .init(text: newText,
                                                                      style: style,
                                                                      marks: marks,
                                                                      checked: newChecked,
                                                                      color: blockColor)

            guard let blockContent = BlocksModelsConverter.convert(middleware: .text(textContent)),
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
            
            updater.update(entry: blockId, update: { (value) in
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
            
            updater.update(entry: blockId, update: { (value) in
                var value = value
                value.information.alignment = modelAlignment
            })
            return .update(.init(updatedIds: [blockId]))
        
        case let .objectDetailsAmend(amend):
            let updatedDetails = BlocksModelsDetailsConverter.asModel(
                details: amend.details
            )
            
            guard !updatedDetails.isEmpty else {
                return nil
            }
            
            let id = amend.id
            
            guard let detailsModel = self.container?.detailsContainer.get(by: id) else {
                return nil
            }
            
            let currentDetailsData = detailsModel.detailsData
            
            var currentDetails = currentDetailsData.details
            updatedDetails.forEach { (key, value) in
                currentDetails[key] = value
            }
        
            // will trigger Publisher
            detailsModel.detailsData = DetailsData(
                details: currentDetails,
                parentId: currentDetailsData.parentId
            )
            
            return .update(EventHandlerUpdatePayload(updatedIds: [id]))
            
        case .objectDetailsUnset:
            assertionFailure("Not implemented")
            return nil
            
        case let .objectDetailsSet(value):
            guard value.hasDetails else {
                return .general
            }
            let detailsId = value.id
            
            let eventsDetails = EventDetailsAndSetDetailsConverter.convert(
                event: Anytype_Event.Object.Details.Set(
                    id: detailsId,
                    details: value.details
                )
            )
            
            let details = BlocksModelsDetailsConverter.asModel(
                details: eventsDetails
            )
            
            if let detailsModel = self.container?.detailsContainer.get(by: detailsId) {
                let model = detailsModel
                let resultDetails = DetailsData(
                    details: details,
                    parentId: detailsId
                )
                
                model.detailsData = resultDetails
            }
            else {
                let detailsData = DetailsData(
                    details: details,
                    parentId: detailsId
                )
                
                let newDetailsModel = LegacyDetailsModel(detailsData: detailsData)

                self.container?.detailsContainer.add(
                    model: newDetailsModel,
                    by: detailsId
                )
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
            return .update(EventHandlerUpdatePayload(updatedIds: [detailsId]))
        case let .blockSetFile(value):
            guard value.hasState else {
                return .general
            }
            
            let blockId = value.id
            let newUpdate = value
            updater.update(entry: blockId, update: { (value) in
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
            
            updater.update(entry: blockId, update: { (value) in
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
            
            updater.update(entry: blockId, update: { (value) in
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
            return .update(EventHandlerUpdatePayload(updatedIds: Set([value.id])))
        
        /// Special case.
        /// After we open document, we would like to receive all blocks of opened page.
        /// For that, we send `blockShow` event to `eventHandler`.
        ///
        case .objectShow: return .general
        default: return nil
        }
    }
}
