import Foundation
import BlocksModels
import Combine
import AnytypeCore

private extension LoggerCategory {
    static let baseDocument: Self = "BaseDocument"
}

final class BaseDocument: BaseDocumentProtocol {
        
    let objectId: BlockId
    
    var onUpdateReceive: ((BaseDocumentUpdateResult) -> Void)?
    
    private let blockActionsService = ServiceLocator.shared.blockActionsServiceSingle()
    var rootActiveModel: BlockModelProtocol? {
        guard let rootId = rootModel?.rootId else { return nil }
        return rootModel?.blocksContainer.model(id: rootId)
    }
    
    var userSession: UserSession? {
        get {
            rootModel?.blocksContainer.userSession
        }
        set {
            guard let newValue = newValue else { return }
            rootModel?.blocksContainer.userSession = newValue
        }
    }
    
    /// RootModel
    private(set) var rootModel: RootBlockContainer? {
        didSet {
            rootModel.flatMap {
                eventHandler.configured($0)
            }
        }
    }
    
    let eventHandler = EventHandler()
    
    /// Services
    private var smartblockService: BlockActionsServiceSingle = .init()
    
    init(objectId: BlockId) {
        self.objectId = objectId
        
        setup()
    }
    
    func setup() {
        eventHandler.onUpdateReceive = { [weak self] update in
            guard update.hasUpdate else { return }
            guard let self = self else { return }
    
            if
               let container = self.rootModel,
               let rootModel = container.blocksContainer.model(id: self.objectId) {
                BlockFlattener.flattenIds(root: rootModel, in: container, options: .default)
            }
            
            let details = self.rootModel?.detailsStorage.get(id: self.objectId)
            
            self.onUpdateReceive?(
                BaseDocumentUpdateResult(
                    updates: update,
                    details: details,
                    models: self.models(from: update)
                )
            )
        }
    }
    
    deinit {
        smartblockService.close(contextId: objectId, blockId: objectId)
    }

    // MARK: - BaseDocumentProtocol

    func open() {
        guard
            let result = blockActionsService.open(
                contextId: objectId,
                blockId: objectId
            )
        else { return }
        
        handleOpen(result)
        eventHandler.handle(
            events: PackOfEvents(middlewareEvents: result.messages)
        )
    }

    // MARK: - Handle Open
    
    private func handleOpen(_ serviceSuccess: ResponseEvent) {
        let blocks = eventHandler.handleBlockShow(
            events: .init(middlewareEvents: serviceSuccess.messages)
        )
        guard let event = blocks.first else { return }
        
        // Build blocks tree and create new container
        // And then, sync builders
        let rootId = serviceSuccess.contextID
        
        let blocksContainer = TreeBlockBuilder.buildBlocksTree(
            from: event.blocks,
            with: rootId
        )
        let detailsStorage = ObjectDetailsStorage()
        event.details.forEach {
            detailsStorage.add(details: $0, id: $0.id)
        }
        
        // Add details models to process.
        rootModel = RootBlockContainer(
            rootId: rootId,
            blocksContainer: blocksContainer,
            detailsStorage: detailsStorage
        )
    }
    
    /// Returns a flatten list of active models of document.
    /// - Returns: A list of active models.
    private func getModels() -> [BlockModelProtocol] {
        guard
            let container = rootModel,
            let activeModel = container.blocksContainer.model(id: container.rootId)
        else {
            AnytypeLogger.create(.baseDocument).debug("getModels. Our document is not ready yet")
            return []
        }
        return BlockFlattener.flatten(root: activeModel, in: container, options: .default)
    }
    
    private func models(from updates: EventHandlerUpdate) -> [BlockModelProtocol] {
        switch updates {
        case .general:
            return getModels()
        case .details:
            return []
        case .update:
            return []
        }
    }

    // MARK: - Details
    /// Return configured details for provided id for listening events.
    ///
    /// Note.
    ///
    /// Provided `id` should be in `a list of details of opened document`.
    /// If you receive a error, assure yourself, that you've opened a document before accessing details.
    ///
    /// - Parameter id: Id of item for which we would like to listen events.
    /// - Returns: details active model.
    ///
    func getDetails(id: BlockId) -> ObjectDetails? {
        let value = self.rootModel?.detailsStorage.get(id: id)
        if value.isNil {
            AnytypeLogger.create(.baseDocument)
                .debug("getDetails(by:). Our document is not ready yet")
        }
        return value
    }
    
    /// Convenient publisher for accessing default details properties by typed enum.
    /// - Returns: Publisher of default details properties.
    func pageDetailsPublisher() -> AnyPublisher<DetailsDataProtocol?, Never> {
        // TODO: - details. implement
        .empty()
    }

    // MARK: - Events
    
    /// Handle events initiated by user.
    ///
    /// - Parameter events: A pack of events.
    ///
    func handle(events: PackOfEvents) {
        eventHandler.handle(events: events)
    }
}
