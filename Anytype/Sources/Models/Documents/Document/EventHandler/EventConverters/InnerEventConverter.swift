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
        switch event {
        case let .blockSetFields(fields):
            updater.update(entry: fields.id) { block in
                var block = block

                block.information.fields = fields.fields.toFieldTypeMap()
                block.didChange()
            }
            return .update(.init(updatedIds: [fields.id]))
        case let .blockAdd(value):
            value.blocks
                .compactMap(BlockModelsInformationConverter.convert(block:))
                .map(BlockModel.init)
                .forEach { block in
                    updater.insert(block: block)
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
        case let .blockSetText(newData):
            return blockSetTextUpdate(newData)
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
        case let .blockSetFile(newData):
            guard newData.hasState else {
                return .general
            }
            
            updater.update(entry: newData.id, update: { block in
                var block = block
                
                switch block.information.content {
                case let .file(fileData):
                    var fileData = fileData
                    
                    if newData.hasType {
                        if let contentType = BlockContentFileContentTypeConverter.asModel(newData.type.value) {
                            fileData.contentType = contentType
                        }
                    }

                    if newData.hasState {
                        if let state = BlockFileStateConverter.asModel(newData.state.value) {
                            fileData.state = state
                        }
                    }
                    
                    if newData.hasName {
                        fileData.metadata.name = newData.name.value
                    }
                    
                    if newData.hasHash {
                        fileData.metadata.hash = newData.hash.value
                    }
                    
                    if newData.hasMime {
                        fileData.metadata.mime = newData.mime.value
                    }
                    
                    if newData.hasSize {
                        fileData.metadata.size = newData.size.value
                    }
                    
                    block.information.content = .file(fileData)
                default: return
                }
            })
            return .update(.init(updatedIds: [newData.id]))
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
    
    private func blockSetTextUpdate(_ newData: Anytype_Event.Block.Set.Text) -> EventHandlerUpdate {
        guard var blockModel = container?.blocksContainer.get(by: newData.id) else {
            assertionFailure("Block model with id \(newData.id) not found in container")
            return .general
        }
        guard case let .text(oldText) = blockModel.information.content else {
            assertionFailure("Block model doesn't support text:\n \(blockModel.information)")
            return .general
        }

        
        let color = newData.hasColor ? newData.color.value : oldText.color
        let text = newData.hasText ? newData.text.value : oldText.attributedText.clearedFromMentionAtachmentsString()
        let checked = newData.hasChecked ? newData.checked.value : oldText.checked
        let style = newData.hasStyle ? newData.style.value : BlockTextContentTypeConverter.asMiddleware(oldText.contentType)
        let marks = buildMarks(newData: newData, oldText: oldText)
        
        let middleContent = Anytype_Model_Block.Content.Text(
            text: text,
            style: style,
            marks: marks,
            checked: checked,
            color: color
        )
        
        guard var textContent = ContentTextConverter().textContent(middleContent) else {
            assertionFailure("We cannot block content from: \(middleContent)")
            return .general
        }

        if !newData.hasStyle {
            textContent.contentType = oldText.contentType
        }
        textContent.number = oldText.number
        
        blockModel.information.content = .text(textContent)
        blockModel.information =  blockValidator.validated(information: blockModel.information)
        
        return .update(.init(updatedIds: [newData.id]))
    }
    
    private func buildMarks(newData: Anytype_Event.Block.Set.Text, oldText: BlockText) -> Anytype_Model_Block.Content.Text.Marks {
        typealias TextConverter = MiddlewareModelsModule.Parsers.Text.AttributedText.Converter
        
        // Apply marks only if we haven't received text and marks.
        let useNewMarks = newData.hasText || newData.marks.hasValue
        var marks = useNewMarks ? newData.marks.value : TextConverter.asMiddleware(attributedText: oldText.attributedText).marks
        
        // Workaroung: Some font could set bold style to attributed string
        // So if header or title style has font that apply bold we remove it
        // We need it if change style from subheading to text
        let oldStyle = BlockTextContentTypeConverter.asMiddleware(oldText.contentType)
        if [.header1, .header2, .header3, .header4, .title].contains(oldStyle) {
            marks.marks.removeAll { mark in
                mark.type == .bold
            }
        }
        
        return marks
    }
}
