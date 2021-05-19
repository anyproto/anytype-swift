import Foundation
import BlocksModels
import Combine
import os


private extension LoggerCategory {
    static let baseDocument: Self = "BaseDocument"
}

/// TODO:
/// Add navigation.
/// For example, we could do the following:
///
/// We could keep a track of opened documents ( list of documents ids )
/// And keep latest ( last ) document as open document.
///
class BaseDocument {
    typealias DetailsContentKind = DetailsContent.Kind
    typealias UserSession = BlockUserSessionModelProtocol
    
    private var rootId: BlockId? { self.rootModel?.rootId }
    
    // TODO: Remove
    var documentId: BlockId? { self.rootId }
    
    /// RootModel
    private var rootModel: ContainerModel? {
        didSet {
            self.handleNewRootModel(self.rootModel)
        }
    }
    
    private let eventProcessor = EventProcessor()
    private let transformer: TreeBlockBuilder = .defaultValue
    
    /// Details Active Models
    /// But we have a lot of them, so, we should keep a list of them.
    /// Or we could create them on the fly.
    ///
    /// This one is active model of default ( or main ) document id (smartblock id).
    ///
    private let defaultDetailsActiveModel: DetailsActiveModel = .init()
    
    /// This event subject is a subject for events from default details active model.
    ///
    /// When we set details, we need to listen for returned value ( success result ).
    /// This success result should be handled by our event processor.
    ///
    private var detailsEventSubject: PassthroughSubject<EventListening.PackOfEvents, Never> = .init()
    
    /// It is simple event subject subscription.
    ///
    /// We use it to subscribe on event subject.
    ///
    private var detailsEventSubjectSubscription: AnyCancellable?
    
    /// Services
    private var smartblockService: BlockActionsServiceSingle = .init()
    
    deinit {
        // TODO:
        // Add closing document without thread.
        // By enhancing code generation.
        if let rootId = self.rootId {
            _ = self.smartblockService.close(contextID: rootId, blockID: rootId)
        }
    }

    // MARK: - Handle Open

    private func handleOpen(_ value: ServiceSuccess) {
        let blocks = self.eventProcessor.handleBlockShow(
            events: .init(contextId: value.contextID, events: value.messages, ourEvents: [])
        )
        guard let event = blocks.first else { return }
        
        // Build blocks tree and create new container
        // And then, sync builders
        let rootId = value.contextID
        
        let blocksContainer = self.transformer.buildBlocksTree(from: event.blocks, with: rootId)
        let parsedDetails = event.details.map(TopLevelBuilderImpl.detailsBuilder.build(information:))
        let detailsContainer = TopLevelBuilderImpl.detailsBuilder.build(list: parsedDetails)
        
        // Add details models to process.
        self.rootModel = TopLevelBuilderImpl.createRootContainer(rootId: rootId, blockContainer: blocksContainer, detailsContainer: detailsContainer)
    }
    
    func open(_ blockId: BlockId) -> AnyPublisher<Void, Error> {
        self.smartblockService.open(contextID: blockId, blockID: blockId).map { [weak self] (value) in
            self?.handleOpen(value)
        }.eraseToAnyPublisher()
    }
    
    func open(_ value: ServiceSuccess) {
        self.handleOpen(value)
        
        // Event processor must receive event to send updates to subscribers.
        // Events are `blockShow`, actually.
        self.eventProcessor.handle(
            events: EventListening.PackOfEvents(
                contextId: value.contextID,
                events: value.messages,
                ourEvents: []
            )
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
    func configureDetails(for container: ContainerModel?) {
        guard let container = container,
              let rootId = container.rootId,
              let ourModel = container.detailsContainer.choose(by: rootId)
        else {
            Logger.create(.baseDocument).debug("configureDetails(for:). Our document is not ready yet")
            return
        }
        let publisher = ourModel.didChangeInformationPublisher()
        self.defaultDetailsActiveModel.configured(documentId: rootId)
        self.defaultDetailsActiveModel.configured(publisher: publisher)
        self.defaultDetailsActiveModel.configured(eventSubject: self.detailsEventSubject)
        self.listenDefaultDetails()
    }

    // MARK: - Handle new root model
    func handleNewRootModel(_ container: ContainerModel?) {
        if let container = container {
            _ = self.eventProcessor.configured(container)
        }
        self.configureDetails(for: container)
    }

    // MARK: - Get models
    typealias ActiveModel = BlockActiveRecordModelProtocol
    
    /// Returns a flatten list of active models of document.
    /// - Returns: A list of active models.
    func getModels() -> [ActiveModel] {
        guard let container = self.rootModel, let rootId = container.rootId, let activeModel = container.blocksContainer.choose(by: rootId) else {
            Logger.create(.baseDocument).debug("getModels. Our document is not ready yet")
            return []
        }
        return BlockFlattener.flatten(root: activeModel, in: container, options: .default)
    }
    
    /// Returns a root active model.
    ///
    /// - Returns: A root active model.
    func getRootActiveModel() -> ActiveModel? {
        guard let rootId = self.rootModel?.rootId else { return nil }
        return self.rootModel?.blocksContainer.choose(by: rootId)
    }
    
    /// Returns a current user session.
    /// - Returns: A current user session
    func getUserSession() -> UserSession? {
        self.rootModel?.blocksContainer.userSession
    }
  
    /// Add it later if needed.
//    /// Returns children ids of provided block id.
//    /// - Parameter id: Parent block id
//    /// - Returns: A list of childrens ids
//    func getChildren(of id: BlockId) -> [BlockId] {
//        self.rootModel?.blocksContainer.children(of: id) ?? []
//    }

    // MARK: - Publishers
    struct UpdateResult {
        var updates: EventHandlerUpdate
        var models: [ActiveModel]
    }
    
    /// A publisher of event processor did process events.
    /// It fires when event processor did finish process events.
    ///
    /// - Returns: A publisher of updates.
    private func updatesPublisher() -> AnyPublisher<EventHandlerUpdate, Never> {
        self.eventProcessor.didProcessEventsPublisher
    }
    
    /// A publisher of updates and current models.
    /// It could filter out updates with empty payload.
    ///
    /// - Returns: A publisher of updates and related models to these updates.
    func modelsAndUpdatesPublisher(
    ) -> AnyPublisher<UpdateResult, Never> {
        self.updatesPublisher().filter(\.hasUpdate)
        .map { [weak self] (value) in
            if let rootId = self?.rootId,
               let container = self?.rootModel,
               let rootModel = container.blocksContainer.choose(by: rootId) {
                BlockFlattener.flattenIds(root: rootModel, in: container, options: .default)
            }
            return UpdateResult(updates: value, models: self?.models(from: value) ?? [])
        }.eraseToAnyPublisher()
    }
    
    private func models(from updates: EventHandlerUpdate) -> [ActiveModel] {
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
    func getDetails(by id: DetailsId) -> DetailsActiveModel? {
        guard let value = self.rootModel?.detailsContainer.choose(by: id) else {
            Logger.create(.baseDocument).debug("getDetails(by:). Our document is not ready yet")
            return nil
        }
        let result: DetailsActiveModel = .init()
        result.configured(documentId: id)
        result.configured(publisher: value.didChangeInformationPublisher())
        return result
    }
    
    /// Returns details accessor associated with corresponding details by id.
    ///
    /// - Parameter id: Id of details
    /// - Returns: Details accessor of this details.
    func getPageDetails(by id: DetailsId) -> DetailsInformationProvider? {
        self.getDetails(by: id).map(\.currentDetails)
    }
    
    /// Convenient publisher for accessing details properties by typed enum.
    ///
    /// Note.
    ///
    /// You should assure yourself, that id should be in a list of details of opened document.
    ///
    /// - Parameter id: Id of item for which we would like to listen events.
    /// - Returns: Publisher of default details properties.
    func getPageDetailsPublisher(by id: DetailsId) -> AnyPublisher<DetailsInformationProvider, Never>? {
        self.getDetails(by: id)?.$currentDetails.eraseToAnyPublisher()
    }
    
    /// Return configured details for listening events.
    ///
    /// Warning!
    ///
    /// If you receive no result, assure that you've opened document before accessing details.
    ///
    func getDefaultDetailsActiveModel() -> DetailsActiveModel {
        self.defaultDetailsActiveModel
    }
    
    /// Returns details accessor associated with corresponding details.
    /// This details accessor associated with default details.
    ///
    /// - Returns: Details accessor of this details.
    func getDefaultPageDetails() -> DetailsInformationProvider {
        self.defaultDetailsActiveModel.currentDetails
    }
    
    /// Convenient publisher for accessing default details properties by typed enum.
    /// - Returns: Publisher of default details properties.
    func getDefaultPageDetailsPublisher() -> AnyPublisher<DetailsInformationProvider, Never> {
        self.getDefaultDetailsActiveModel().$currentDetails.eraseToAnyPublisher()
    }

    // MARK: - Details Conversion to Blocks.
    /// Deprecated.
    ///
    /// Now we use view models that uses only blocks.
    /// So, we have to convert our details to blocks first.
    private func convert(_ detailsActiveModel: DetailsActiveModel, of kind: DetailsContentKind) -> ActiveModel? {
        guard let rootId = self.rootId else {
            Logger.create(.baseDocument).debug("convert(_:of:). Our document is not ready yet.")
            return nil
        }
                
        let detailsContent: DetailsContent? = {
            let details = detailsActiveModel.currentDetails

            switch kind {
            case .title:
                return .title(details.title ?? .init(value: ""))
            case .iconEmoji:
                return details.iconEmoji.flatMap { DetailsContent.iconEmoji($0) }
            case .iconColor:
                return .iconColor(details.iconColor ?? .init(value: ""))
            case .iconImage:
                return .iconImage(details.iconImage ?? .init(value: ""))
            }
        }()
        
        guard let unwrappedDetailsContent = detailsContent else { return nil }
        
        let block = BlockInformation.DetailsAsBlockConverter(
            blockId: rootId
        ).convertDetailsToBlock(unwrappedDetailsContent)
        
        let blockFromContainer = self.rootModel?.blocksContainer.get(by: block.information.id)
        if !blockFromContainer.isNil {
            Logger.create(.baseDocument).debug("convert(_:of:). We have already added details with id: \(block.information.id)")
        }
        else {
            self.rootModel?.blocksContainer.add(block)
        }
        
        return self.rootModel?.blocksContainer.choose(by: block.information.id)
    }
    
    func getDefaultDetailsActiveModel(of kind: DetailsContentKind) -> ActiveModel? {
        self.convert(self.defaultDetailsActiveModel, of: kind)
    }

    // MARK: - Events
    typealias Events = EventListening.PackOfEvents
    
    /// Handle events initiated by user.
    ///
    /// - Parameter events: A pack of events.
    ///
    func handle(events: Events) {
        self.eventProcessor.handle(events: events)
    }
}
