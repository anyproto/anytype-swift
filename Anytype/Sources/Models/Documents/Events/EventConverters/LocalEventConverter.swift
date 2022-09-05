import BlocksModels
import ProtobufMessages
import AnytypeCore

final class LocalEventConverter {
    private let objectId: String
    private let infoContainer: InfoContainerProtocol
    private let blockValidator = BlockValidator()
    private let detailsStorage = ObjectDetailsStorage.shared
    private let relationLinksStorage: RelationLinksStorageProtocol
//    private let relationStorage: RelationsMetadataStorageProtocol
    private let restrictionsContainer: ObjectRestrictionsContainer
    
    init(
        objectId: String,
//        relationStorage: RelationsMetadataStorageProtocol,
        relationLinksStorage: RelationLinksStorageProtocol,
        restrictionsContainer: ObjectRestrictionsContainer,
        infoContainer: InfoContainerProtocol
    ) {
        self.objectId = objectId
//        self.relationStorage = relationStorage
        self.relationLinksStorage = relationLinksStorage
        self.restrictionsContainer = restrictionsContainer
        self.infoContainer = infoContainer
    }
    
    func convert(_ event: LocalEvent) -> DocumentUpdate? {
        switch event {
        case .setToggled, .documentClosed, .setStyle, .general:
            return .general
        case let .setText(blockId: blockId, text: text):
            return blockSetTextUpdate(blockId: blockId, text: text)
        case .setLoadingState(blockId: let blockId):
            guard var info = infoContainer.get(id: blockId) else {
                anytypeAssertionFailure("setLoadingState. Can't find model by id \(blockId)", domain: .localEventConverter)
                return nil
            }
            guard case var .file(content) = info.content else {
                anytypeAssertionFailure("Not file content of block \(blockId) for setLoading action", domain: .localEventConverter)
                return nil
            }
            
            content.state = .uploading
            info = info.updated(content: .file(content))
            infoContainer.add(info)
            return .blocks(blockIds: [blockId])
        case .reload(blockId: let blockId):
            return .blocks(blockIds: [blockId])
        case .header(let data):
            return .header(data)
        case .objectShow(let data):
            guard data.rootID.isNotEmpty else {
                anytypeAssertionFailure("Empty root id", domain: .middlewareEventConverter)
                return nil
            }

            let parsedBlocks = data.blocks.compactMap {
                BlockInformationConverter.convert(block: $0)
            }
            
            let parsedDetails: [ObjectDetails] = data.details.compactMap {
                ObjectDetails(id: $0.id, values: $0.details.fields)
            }

            buildBlocksTree(information: parsedBlocks, rootId: data.rootID, container: infoContainer)

            parsedDetails.forEach { detailsStorage.add(details: $0) }
    
            #warning("Check me")
            let relationLinks = data.relationLinks.map { RelationLink(middlewareRelationLink: $0) }
            relationLinksStorage.set(relationLinks: relationLinks)
            RelationDetailsStorage.shared.subscribeForLocalEvents(contextId: objectId, links: relationLinks)
            
//            relationStorage.set(
//                relations: data.relations.map { RelationMetadata(middlewareRelation: $0) }
//            )
            let restrinctions = MiddlewareObjectRestrictionsConverter.convertObjectRestrictions(middlewareRestrictions: data.restrictions)

            restrictionsContainer.restrinctions = restrinctions
            return .general
        case .relationChanged:
            return .general
        }
    }
    
    // simplified version of inner converter method
    // func blockSetTextUpdate(_ newData: Anytype_Event.Block.Set.Text)
    // only text is changed
    private func blockSetTextUpdate(blockId: BlockId, text: MiddlewareString) -> DocumentUpdate {
        guard var info = infoContainer.get(id: blockId) else {
            anytypeAssertionFailure("Block model with id \(blockId) not found in container", domain: .localEventConverter)
            return .general
        }
        guard case let .text(oldText) = info.content else {
            anytypeAssertionFailure("Block model doesn't support text:\n \(info)", domain: .localEventConverter)
            return .general
        }
        
        let middleContent = Anytype_Model_Block.Content.Text(
            text: text.text,
            style: oldText.contentType.asMiddleware,
            marks: text.marks,
            checked: oldText.checked,
            color: oldText.color?.rawValue ?? "",
            iconEmoji: oldText.iconEmoji,
            iconImage: oldText.iconImage
        )
        
        guard var textContent = middleContent.textContent else {
            anytypeAssertionFailure("We cannot block content from: \(middleContent)", domain: .localEventConverter)
            return .general
        }

        textContent.contentType = oldText.contentType
        textContent.number = oldText.number
        
        info = info.updated(content: .text(textContent))
        info = blockValidator.validated(information: info)
        infoContainer.add(info)
        
        return .blocks(blockIds: [blockId])
    }
    
    private func buildBlocksTree(information: [BlockInformation], rootId: BlockId, container: InfoContainerProtocol) {
        
        information.forEach { container.add($0) }
        let roots = information.filter { $0.id == rootId }

        guard roots.count != 0 else {
            anytypeAssertionFailure("Unknown situation. We can't have zero roots.", domain: .middlewareEventConverter)
            return
        }

        if roots.count != 1 {
            // this situation is not possible, but, let handle it.
            anytypeAssertionFailure(
                "We have several roots for our rootId. Not possible, but let us handle it.",
                domain: .middlewareEventConverter
            )
        }

        let rootId = roots[0].id

        IndentationBuilder.build(container: container, id: rootId)
    }
}
