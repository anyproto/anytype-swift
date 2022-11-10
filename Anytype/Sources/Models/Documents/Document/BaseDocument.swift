import BlocksModels
import Combine
import AnytypeCore
import Foundation

final class BaseDocument: BaseDocumentProtocol {
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> { updateSubject.eraseToAnyPublisher() }
    let objectId: BlockId
    private(set) var isOpened = false

    let infoContainer: InfoContainerProtocol = InfoContainer()
    let relationLinksStorage: RelationLinksStorageProtocol = RelationLinksStorage()
    let restrictionsContainer: ObjectRestrictionsContainer = ObjectRestrictionsContainer()
    
    var objectRestrictions: ObjectRestrictions { restrictionsContainer.restrinctions }

    var isLocked: Bool {
        guard let isLockedField = infoContainer.get(id: objectId)?
                .fields[BlockFieldBundledKey.isLocked.rawValue],
              case let .boolValue(isLocked) = isLockedField.kind else {
            return false
        }

        return isLocked
    }
    
    private let blockActionsService: BlockActionsServiceSingleProtocol
    private let eventsListener: EventsListener
    private let updateSubject = PassthroughSubject<DocumentUpdate, Never>()
    private let relationBuilder = RelationsBuilder()
    private let detailsStorage = ObjectDetailsStorage.shared
    private let relationDetailsStorage = ServiceLocator.shared.relationDetailsStorage()

    private var subscriptions = [AnyCancellable]()
    
    // MARK: - State
    @Published private var documentDetails = ObjectDetails(id: "")
    @Published private var parsedRelations2: ParsedRelations = ParsedRelations(featuredRelations: [], otherRelations: [])
    var parsedRelationsPublisher: AnyPublisher<ParsedRelations, Never> {
        $parsedRelations2.eraseToAnyPublisher()
    }
    
    @Published private var _isLocked = false
    var isLockedPublisher: AnyPublisher<Bool, Never> {
        $_isLocked.eraseToAnyPublisher()
    }
    
    var parsedRelations: ParsedRelations {
        relationBuilder.parsedRelations(
            relationsDetails: relationDetailsStorage.relationsDetails(for: relationLinksStorage.relationLinks),
            objectId: objectId,
            isObjectLocked: isLocked
        )
    }
        
    init(objectId: BlockId) {
        self.objectId = objectId
        
        self.eventsListener = EventsListener(
            objectId: objectId,
            infoContainer: infoContainer,
            relationLinksStorage: relationLinksStorage,
            restrictionsContainer: restrictionsContainer
        )
        
        self.blockActionsService = ServiceLocator.shared.blockActionsServiceSingle(contextId: objectId)
        
        setup()
    }
    
    deinit {
        Task.detached(priority: .userInitiated) { [blockActionsService] in
            try await blockActionsService.close()
        }
    }

    // MARK: - BaseDocumentProtocol
    
    @MainActor
    func open() async throws {
        try await blockActionsService.open()
        isOpened = true
    }
    
    @MainActor
    func openForPreview() async throws {
        try await blockActionsService.openForPreview()
        isOpened = true
    }
    
    @MainActor
    func close() async throws {
        try await blockActionsService.close()
        isOpened = false
    }
    
    var details: ObjectDetails? {
        detailsStorage.get(id: objectId)
    }
    
    var children: [BlockInformation] {
        guard let model = infoContainer.get(id: objectId) else {
            return []
        }
        return model.flatChildrenTree(container: infoContainer)
    }

    var isEmpty: Bool {
        let filteredBlocks = children.filter { $0.isFeaturedRelations || $0.isText }

        if filteredBlocks.count > 0 { return false }
        let allTextChilds = children.filter(\.isText)

        if allTextChilds.count > 1 { return false }

        return allTextChilds.first?.content.isEmpty ?? false
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
        
        ObjectDetailsStorage.shared.publisherFor(id: objectId)
            .assign(to: &$documentDetails)
        
        infoContainer.publisherFor(id: objectId)
            .map { container in
                guard let isLockedField = container.fields[BlockFieldBundledKey.isLocked.rawValue],
                      case let .boolValue(isLocked) = isLockedField.kind else {
                    return false
                }

                return isLocked
            }
            .assign(to: &$_isLocked)
        
        Publishers
            .CombineLatest3(
                relationLinksStorage.relationLinksPublisher,
                relationDetailsStorage.relationsDetailsPublisher,
                $documentDetails
            )
            .map { [weak self] links, relationDetails, _ in
                guard let self = self else { return ParsedRelations(featuredRelations: [], otherRelations: []) }
                let data = self.relationBuilder.parsedRelations(
                    relationsDetails: self.relationDetailsStorage.relationsDetails(for: links),
                    objectId: self.objectId,
                    isObjectLocked: self.isLocked
                )
                return data
            }
            .assign(to: &$parsedRelations2)
    }
}
