import Foundation
import BlocksModels
import Combine
import os

private extension LoggerCategory {
    static let baseDocument: Self = "BaseDocument"
}

final class BaseDocument: BaseDocumentProtocol {
    var rootActiveModel: BlockActiveRecordProtocol? {
        guard let rootId = rootModel?.rootId else { return nil }
        return rootModel?.blocksContainer.choose(by: rootId)
    }
    
    var userSession: BlockUserSessionModelProtocol? {
        rootModel?.blocksContainer.userSession
    }

    var documentId: BlockId? { rootModel?.rootId }
    
    /// RootModel
    private var rootModel: ContainerModelProtocol? {
        didSet {
            self.handleNewRootModel(self.rootModel)
        }
    }
    
    private let eventHandler = EventHandler()
    
    /// Details Active Models
    /// But we have a lot of them, so, we should keep a list of them.
    /// Or we could create them on the fly.
    ///
    /// This one is active model of default ( or main ) document id (smartblock id).
    ///
    let defaultDetailsActiveModel = DetailsActiveModel()
    
    /// This event subject is a subject for events from default details active model.
    ///
    /// When we set details, we need to listen for returned value ( success result ).
    /// This success result should be handled by our event processor.
    ///
    private var detailsEventSubject: PassthroughSubject<PackOfEvents, Never> = .init()
    
    /// It is simple event subject subscription.
    ///
    /// We use it to subscribe on event subject.
    ///
    private var detailsEventSubjectSubscription: AnyCancellable?
    
    /// Services
    private var smartblockService: BlockActionsServiceSingle = .init()
    
    deinit {
        documentId.flatMap { rootId in
            _ = self.smartblockService.close(contextID: rootId, blockID: rootId)
        }
    }

    // MARK: - BaseDocumentProtocol

    var updateBlockModelPublisher: AnyPublisher<BaseDocumentUpdateResult, Never> {
        eventHandler.didProcessEventsPublisher.filter(\.hasUpdate)
            .map { [weak self] updates in
                if let rootId = self?.documentId,
                   let container = self?.rootModel,
                   let rootModel = container.blocksContainer.choose(by: rootId) {
                    BlockFlattener.flattenIds(root: rootModel, in: container, options: .default)
                }
                return BaseDocumentUpdateResult(updates: updates, models: self?.models(from: updates) ?? [])
            }.eraseToAnyPublisher()
    }

    // MARK: - Handle Open
    private func open(_ blockId: BlockId) -> AnyPublisher<Void, Error> {
        self.smartblockService.open(contextID: blockId, blockID: blockId).map { [weak self] serviceSuccess in
            self?.handleOpen(serviceSuccess)
        }.eraseToAnyPublisher()
    }
    
    func open(_ value: ServiceSuccess) {
        self.handleOpen(value)
        
        // Event processor must receive event to send updates to subscribers.
        // Events are `blockShow`, actually.
        eventHandler.handle(
            events: PackOfEvents(
                contextId: value.contextID,
                events: value.messages,
                ourEvents: []
            )
        )
    }
    
    private func handleOpen(_ value: ServiceSuccess) {
        let blocks = eventHandler.handleBlockShow(
            events: .init(contextId: value.contextID, events: value.messages, ourEvents: [])
        )
        guard let event = blocks.first else { return }
        
        // Build blocks tree and create new container
        // And then, sync builders
        let rootId = value.contextID
        
        let blocksContainer = TreeBlockBuilder.buildBlocksTree(from: event.blocks, with: rootId)
        let parsedDetails = event.details.map {
            LegacyDetailsModel(detailsData: $0)
        }
        
        let detailsStorage = DetailsBuilder.emptyDetailsContainer()
        parsedDetails.forEach {
            detailsStorage.add(
                model: $0,
                by: $0.detailsData.parentId
            )
        }
        
        // Add details models to process.
        self.rootModel = RootBlocksContainer(
            rootId: rootId,
            blocksContainer: blocksContainer,
            detailsContainer: detailsStorage
        )
    }

    // MARK: - Configure Details

    // Configure a subscription on events stream from details.
    // We need it for set details success result to process it in our event processor.
    private func listenDefaultDetails() {
        self.detailsEventSubjectSubscription = self.detailsEventSubject.sink(receiveValue: { [weak self] (value) in
            self?.handle(events: value)
        })
    }
    
    /// Configure default details for a container.
    ///
    /// It is the first place where you can configure default details with various handlers and other stuff.
    ///
    /// - Parameter container: A container in which this details is default.
    private func configureDetails(for container: ContainerModelProtocol?) {
        guard let container = container,
              let rootId = container.rootId,
              let ourModel = container.detailsContainer.get(by: rootId)
        else {
            Logger.create(.baseDocument).debug("configureDetails(for:). Our document is not ready yet")
            return
        }
        let publisher = ourModel.changeInformationPublisher
        self.defaultDetailsActiveModel.configured(documentId: rootId)
        self.defaultDetailsActiveModel.configured(publisher: publisher)
        self.defaultDetailsActiveModel.configured(eventSubject: self.detailsEventSubject)
        self.listenDefaultDetails()
    }

    // MARK: - Handle new root model
    private func handleNewRootModel(_ container: ContainerModelProtocol?) {
        if let container = container {
            eventHandler.configured(container)
        }
        configureDetails(for: container)
    }
    
    /// Returns a flatten list of active models of document.
    /// - Returns: A list of active models.
    private func getModels() -> [BlockActiveRecordProtocol] {
        guard let container = self.rootModel, let rootId = container.rootId, let activeModel = container.blocksContainer.choose(by: rootId) else {
            Logger.create(.baseDocument).debug("getModels. Our document is not ready yet")
            return []
        }
        return BlockFlattener.flatten(root: activeModel, in: container, options: .default)
    }
    
    private func models(from updates: EventHandlerUpdate) -> [BlockActiveRecordProtocol] {
        switch updates {
        case .general:
            return getModels()
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
    func getDetails(by id: ParentId) -> DetailsActiveModel? {
        guard let value = self.rootModel?.detailsContainer.get(by: id) else {
            Logger.create(.baseDocument).debug("getDetails(by:). Our document is not ready yet")
            return nil
        }
        let result: DetailsActiveModel = .init()
        result.configured(documentId: id)
        result.configured(publisher: value.changeInformationPublisher)
        return result
    }
    
    /// Convenient publisher for accessing default details properties by typed enum.
    /// - Returns: Publisher of default details properties.
    func pageDetailsPublisher() -> AnyPublisher<DetailsData?, Never> {
        defaultDetailsActiveModel.$currentDetails.eraseToAnyPublisher()
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
