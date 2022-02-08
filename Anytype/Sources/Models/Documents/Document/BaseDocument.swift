import Foundation
import BlocksModels
import Combine
import AnytypeCore
import ProtobufMessages


private extension LoggerCategory {
    static let baseDocument: Self = "BaseDocument"
}

final class BaseDocument: BaseDocumentProtocol {
    var updatePublisher: AnyPublisher<EventsListenerUpdate, Never> { updateSubject.eraseToAnyPublisher() }
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    private let eventsListener: EventsListener
    private let updateSubject = PassthroughSubject<EventsListenerUpdate, Never>()
    private let relationBuilder = RelationsBuilder()
    private let detailsStorage = ObjectDetailsStorage.shared
    
    let objectId: BlockId

    let blocksContainer: BlockContainerModelProtocol = BlockContainer()
    let relationsStorage: RelationsMetadataStorageProtocol = RelationsMetadataStorage()
    
    private(set) var objectRestrictions: ObjectRestrictions = ObjectRestrictions()

    var parsedRelations: ParsedRelations {
        relationBuilder.parsedRelations(
            relationMetadatas: relationsStorage.relations,
            objectId: objectId
        )
    }
        
    init(objectId: BlockId) {
        self.objectId = objectId
        
        self.eventsListener = EventsListener(
            objectId: objectId,
            blocksContainer: blocksContainer,
            relationStorage: relationsStorage
        )
        
        setup()
    }
    
    deinit {
        blockActionsService.close(contextId: objectId, blockId: objectId)
    }

    // MARK: - BaseDocumentProtocol

    func open() -> Bool {
        guard let result = blockActionsService.open(contextId: objectId, blockId: objectId) else {
            return false
        }
        
        handleObjectShowResponse(response: result)
        
        EventsBunch(contextId: objectId, middlewareEvents: result.messages).send()
        return true
    }
    
    func close(){
        blockActionsService.close(contextId: objectId, blockId: objectId)
    }
    
    var objectDetails: ObjectDetails? {
        detailsStorage.get(id: objectId)
    }
    
    // Looks like this code runs on main thread.
    // This operation should be done in `eventsListener.onUpdateReceive` closure
    // OR store flatten blocks instead of tree in `BlockContainer`
    var flattenBlocks: [BlockModelProtocol] {
        guard
            let activeModel = blocksContainer.model(id: objectId)
        else {
            AnytypeLogger.create(.baseDocument).debug("getModels. Our document is not ready yet")
            return []
        }
        return BlockFlattener.flatten(
            root: activeModel,
            in: blocksContainer,
            options: .default
        )
    }

    
    
    private func setup() {
        eventsListener.onUpdateReceive = { [weak self] update in
            guard update.hasUpdate else { return }
            guard let self = self else { return }
            
            DispatchQueue.main.async { [weak self] in
                self?.updateSubject.send(update)
            }
        }
        eventsListener.startListening()
    }

    private func handleObjectShowResponse(response: MiddlewareResponse) {
        let objectShowEvent = showEventsFromMessages(response.messages).first
        guard let objectShowEvent = objectShowEvent else { return }

        let rootId = objectShowEvent.rootID
        guard rootId.isNotEmpty else { return }

        let parsedBlocks = objectShowEvent.blocks.compactMap {
            BlockInformationConverter.convert(block: $0)
        }
        let parsedDetails = objectShowEvent.details.map {
            ObjectDetails(
                id: $0.id,
                values: $0.details.fields
            )
        }

        TreeBlockBuilder.buildBlocksTree(from: parsedBlocks, with: rootId, in: blocksContainer)

        parsedDetails.forEach { detailsStorage.add(details: $0) }
        
        relationsStorage.set(
            relations: objectShowEvent.relations.map { RelationMetadata(middlewareRelation: $0) }
        )
        
        objectRestrictions = MiddlewareObjectRestrictionsConverter.convertObjectRestrictions(middlewareResctrictions: objectShowEvent.restrictions)
    }

    private func showEventsFromMessages(_ messages: [Anytype_Event.Message]) -> [Anytype_Event.Object.Show] {
        messages
            .compactMap { $0.value }
            .compactMap { value -> Anytype_Event.Object.Show? in
                guard case .objectShow(let event) = value else { return nil }
                return event
            }
    }
}
