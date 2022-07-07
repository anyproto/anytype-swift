import BlocksModels
import Combine
import AnytypeCore
import Foundation

final class BaseDocument: BaseDocumentProtocol {
    var updatePublisher: AnyPublisher<DocumentUpdate, Never> { updateSubject.eraseToAnyPublisher() }
    let objectId: BlockId
    private(set) var isOpened = false

    let infoContainer: InfoContainerProtocol = InfoContainer()
    let relationsStorage: RelationsMetadataStorageProtocol = RelationsMetadataStorage()
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

    var parsedRelations: ParsedRelations {
        relationBuilder.parsedRelations(
            relationMetadatas: relationsStorage.relations,
            objectId: objectId,
            isObjectLocked: isLocked
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
        
        self.blockActionsService = ServiceLocator.shared.blockActionsServiceSingle(contextId: objectId)
        
        setup()
    }
    
    deinit {
        close()
    }

    // MARK: - BaseDocumentProtocol

    @discardableResult
    func open() -> Bool {
        ObjectTypeProvider.shared.resetCache()
        isOpened = blockActionsService.open()
        return isOpened
    }

    @discardableResult
    func openForPreview() -> Bool {
        isOpened = blockActionsService.openForPreview()
        return isOpened
    }
    
    func close(){
        blockActionsService.close()
    }
    
    var details: ObjectDetails? {
        detailsStorage.get(id: objectId)
    }
    
    var children: [BlockInformation] {
        guard let model = infoContainer.get(id: objectId) else {
            anytypeAssertionFailure("getModels. Our document is not ready yet", domain: .baseDocument)
            return []
        }
        return model.flatChildrenTree(container: infoContainer)
    }

    var isEmpty: Bool {
        guard let details = details else {
            return false
        }

        let allTextChilds = children.filter(\.isText)
        if allTextChilds.count > 1 { return false }

        return allTextChilds.first?.content.isEmpty ?? true

//        switch details.layout {
//        case .note:
//
//        case .basic, .profile, .todo, .set:
//            return
//        }
//
//
//        let hasNonTextAndRelationBlocks = items.onlyBlockViewModels.contains {
//            switch $0.content {
//            case .text, .featuredRelations:
//                return false
//            default:
//                return true
//            }
//        }
//
//        if hasNonTextAndRelationBlocks { return false }
//
//        let textBlocks = items.onlyBlockViewModels.filter { $0.content.isText }
//
//        switch textBlocks.count {
//        case 0, 1:
//            return true
//        case 2:
//            return textBlocks.last?.content.isEmpty ?? false
//        default:
//            return false
//        }
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
