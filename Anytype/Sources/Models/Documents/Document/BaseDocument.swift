import BlocksModels
import Combine
import AnytypeCore


final class BaseDocument: BaseDocumentProtocol {
    var updatePublisher: AnyPublisher<EventsListenerUpdate, Never> { updateSubject.eraseToAnyPublisher() }
    let objectId: BlockId

    let infoContainer: InfoContainerProtocol = InfoContainer()
    let relationsStorage: RelationsMetadataStorageProtocol = RelationsMetadataStorage()
    let restrictionsContainer: ObjectRestrictionsContainer = ObjectRestrictionsContainer()
    
    var objectRestrictions: ObjectRestrictions {
        restrictionsContainer.restrinctions
    }
    
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    private let eventsListener: EventsListener
    private let updateSubject = PassthroughSubject<EventsListenerUpdate, Never>()
    private let relationBuilder = RelationsBuilder()
    private let detailsStorage = ObjectDetailsStorage.shared

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
            infoContainer: infoContainer,
            relationStorage: relationsStorage,
            restrictionsContainer: restrictionsContainer
        )
        
        setup()
    }
    
    deinit {
        blockActionsService.close(contextId: objectId, blockId: objectId)
    }

    // MARK: - BaseDocumentProtocol

    func open() -> Bool {
        return blockActionsService.open(contextId: objectId, blockId: objectId)
    }
    
    func close(){
        blockActionsService.close(contextId: objectId, blockId: objectId)
    }
    
    var objectDetails: ObjectDetails? {
        detailsStorage.get(id: objectId)
    }
    
    #warning("TODO")
    // Looks like this code runs on main thread.
    // This operation should be done in `eventsListener.onUpdateReceive` closure
    // OR store children blocks instead of tree in `InfoContainer`
    var children: [BlockInformation] {
        guard let model = infoContainer.get(id: objectId) else {
            anytypeAssertionFailure("getModels. Our document is not ready yet", domain: .baseDocument)
            return []
        }
        return model.flatChildrenTree(container: infoContainer)
    }

    // MARK: - Private methods
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
}
