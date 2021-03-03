//
//  DocumentModule+Document+BaseDocument.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 26.01.2021.
//  Copyright © 2021 AnyType. All rights reserved.
//

import Foundation
import BlocksModels
import Combine
import os

fileprivate typealias Namespace = DocumentModule.Document
fileprivate typealias FileNamespace = Namespace.BaseDocument

private extension Logging.Categories {
    static let baseDocument: Self = "DocumentModule.Document.BaseDocument"
}

extension Namespace {
    /// TODO:
    /// Add navigation.
    /// For example, we could do the following:
    ///
    /// We could keep a track of opened documents ( list of documents ids )
    /// And keep latest ( last ) document as open document.
    ///
    class BaseDocument {
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias DetailsId = TopLevel.AliasesMap.DetailsId
        typealias RootModel = TopLevelContainerModelProtocol
        typealias Transformer = TopLevel.AliasesMap.BlockTools.Transformer.FinalTransformer
        typealias DetailsAccessor = TopLevel.AliasesMap.DetailsUtilities.InformationAccessor        
        
        typealias DetailsActiveModel = DocumentModule.Document.DetailsActiveModel
        typealias DetailsContentKind = TopLevel.AliasesMap.DetailsContent.Kind
        
        typealias UserSession = BlockUserSessionModelProtocol
        
        /// RootId
        private var rootId: BlockId? { self.rootModel?.rootId }
        
        /// TODO:
        /// Remove it later.
        /// We have to keep it private.
        /// For now it is ok.
        ///
        var documentId: BlockId? { self.rootId }
        
        /// RootModel
        private var rootModel: RootModel? {
            didSet {
                self.handleNewRootModel(self.rootModel)
            }
        }
        
        /// Event Processing
        private let eventProcessor: DocumentModule.EventProcessor = .init()
        
        /// Data transformer
        private let transformer: Transformer = .defaultValue
        
        /// Details Active Models
        /// But we have a lot of them, so, we should keep a list of them.
        /// Or we could create them on the fly.
        ///
        /// This one is active model of default ( or main ) document id (smartblock id).
        ///
        private var defaultDetailsActiveModel: DetailsActiveModel = .init()
        
        /// This event subject is a subject for events from default details active model.
        ///
        /// When we set details, we need to listen for returned value ( success result ).
        /// This success result should be handled by our event processor.
        ///
        private var detailsEventSubject: PassthroughSubject<DetailsActiveModel.Events, Never> = .init()
        
        /// It is simple event subject subscription.
        ///
        /// We use it to subscribe on event subject.
        ///
        private var detailsEventSubjectSubscription: AnyCancellable?
        
        /// Services
        private var smartblockService: ServiceLayerModule.Single.BlockActionsService = .init()
        
        init() {}
        
        deinit {
            /// TODO:
            /// Add closing document without thread.
            /// By enhancing code generation.
            ///
            if let rootId = self.rootId {
                _ = self.smartblockService.close.action(contextID: rootId, blockID: rootId)
            }
        }
    }
}

// MARK: - Handle Open
extension FileNamespace {
    private func handleOpen(_ value: ServiceLayerModule.Success) {
        let blocks = self.eventProcessor.handleBlockShow(events: .init(contextId: value.contextID, events: value.messages, ourEvents: []))
        guard let event = blocks.first else { return }
        
        /// Now transform and create new container.
        ///
        /// And then, sync builders...
        
        let rootId = value.contextID
        
        let blocksContainer = self.transformer.transform(event.blocks, rootId: rootId)
        let parsedDetails = event.details.map(TopLevel.Builder.detailsBuilder.build(information:))
        let detailsContainer = TopLevel.Builder.detailsBuilder.build(list: parsedDetails)
        
        /// Add details models to process.
        self.rootModel = TopLevel.Builder.build(rootId: rootId, blockContainer: blocksContainer, detailsContainer: detailsContainer)
    }
    
    func open(_ blockId: BlockId) -> AnyPublisher<Void, Error> {
        /// What to do on open?
        self.smartblockService.open.action(contextID: blockId, blockID: blockId).map { [weak self] (value) in
            self?.handleOpen(value)
        }.eraseToAnyPublisher()
    }
    
    func open(_ value: ServiceLayerModule.Success) {
        self.handleOpen(value)
        
        /// Why?
        /// Event processor must receive event to send updates to subscribers.
        /// Events are `blockShow`, actually.
        ///
        self.eventProcessor.handle(events: .init(contextId: value.contextID, events: value.messages, ourEvents: []))
    }
}

// MARK: - Configure Details
private extension FileNamespace {
    /// Configure a subscription on events stream from details.
    /// We need it for set details success result to process it in our event processor.
    ///
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
    func configureDetails(for container: RootModel?) {
        guard let container = container, let rootId = container.rootId, let ourModel = container.detailsContainer.choose(by: rootId) else {
            let logger = Logging.createLogger(category: .baseDocument)
            os_log(.debug, log: logger, "configureDetails(for:). Our document is not ready yet")
            return
        }
        let publisher = ourModel.didChangeInformationPublisher()
        _ = self.defaultDetailsActiveModel.configured(documentId: rootId)
        self.defaultDetailsActiveModel.configured(publisher: publisher)
        self.defaultDetailsActiveModel.configured(eventSubject: self.detailsEventSubject)
        self.listenDefaultDetails()
    }
}

// MARK: - Handle new root model
private extension FileNamespace {
    func handleNewRootModel(_ container: RootModel?) {
        if let container = container {
            _ = self.eventProcessor.configured(container)
        }
        self.configureDetails(for: container)
    }
}

// MARK: - Get models
extension FileNamespace {
    typealias ActiveModel = BlockActiveRecordModelProtocol
    
    /// Returns a flatten list of active models of document.
    ///
    /// Discussion
    /// For our view we have to return a flat list of view models.
    ///
    /// - Returns: A list of active models.
    func getModels() -> [ActiveModel] {
        guard let container = self.rootModel, let rootId = container.rootId, let activeModel = container.blocksContainer.choose(by: rootId) else {
            let logger = Logging.createLogger(category: .baseDocument)
            os_log(.debug, log: logger, "getModels. Our document is not ready yet")
            return []
        }
        return DocumentModule.Document.BaseFlattener.flatten(root: activeModel, in: container, options: .default)
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
}

// MARK: - Publishers
extension FileNamespace {
    typealias ModelsUpdates = DocumentModule.EventProcessor.EventHandler.Update
    struct UpdateResult {
        var updates: ModelsUpdates
        var models: [ActiveModel]
    }
    
    /// A publisher of event processor did process events.
    /// It fires when event processor did finish process events.
    ///
    /// - Returns: A publisher of updates.
    private func updatesPublisher() -> AnyPublisher<ModelsUpdates, Never> {
        self.eventProcessor.didProcessEventsPublisher
    }
    
    /// A publisher of updates and current models.
    /// It could filter out updates with empty payload.
    ///
    /// - Parameter includeEmptyUpdates: A flag indicates whether you need to include empty updates or not.
    /// - Returns: A publisher of updates and related models to these updates.
    func modelsAndUpdatesPublisher(includeEmptyUpdates: Bool = false) -> AnyPublisher<UpdateResult, Never> {
        let publisher: AnyPublisher<ModelsUpdates, Never> = includeEmptyUpdates ? self.updatesPublisher() :
            self.updatesPublisher()
            .filter({ (value) -> Bool in
                switch value {
                case .empty: return false
                default: return true
                }
            }).eraseToAnyPublisher()
        
        return publisher.map { [weak self] (value) in
            .init(updates: value, models: self?.getModels() ?? [])
        }.eraseToAnyPublisher()
    }
}

// MARK: - Details
extension FileNamespace {
    
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
            let logger = Logging.createLogger(category: .baseDocument)
            os_log(.debug, log: logger, "getDetails(by:). Our document is not ready yet")
            return nil
        }
        let result: DetailsActiveModel = .init()
        _ = result.configured(documentId: id)
        result.configured(publisher: value.didChangeInformationPublisher())
        return result
    }
    
    /// Returns details accessor associated with corresponding details by id.
    ///
    /// - Parameter id: Id of details
    /// - Returns: Details accessor of this details.
    func getDetailsAccessor(by id: DetailsId) -> DetailsAccessor? {
        self.getDetails(by: id).map(\.currentDetails).map(DetailsAccessor.init)
    }
    
    /// Convenient publisher for accessing details properties by typed enum.
    ///
    /// Note.
    ///
    /// You should assure yourself, that id should be in a list of details of opened document.
    ///
    /// - Parameter id: Id of item for which we would like to listen events.
    /// - Returns: Publisher of default details properties.
    func getDetailsAccessorPublisher(by id: DetailsId) -> AnyPublisher<DetailsAccessor, Never>? {
        self.getDetails(by: id)?.$currentDetails.map(DetailsAccessor.init).eraseToAnyPublisher()
    }
    
    /// Return configured details for listening events.
    ///
    /// Warning!
    ///
    /// If you receive no result, assure that you've opened document before accessing details.
    ///
    func getDefaultDetails() -> DetailsActiveModel {
        self.defaultDetailsActiveModel
    }
    
    /// Returns details accessor associated with corresponding details.
    /// This details accessor associated with default details.
    ///
    /// - Returns: Details accessor of this details.
    func getDefaultDetailsAccessor() -> DetailsAccessor {
        .init(value: self.defaultDetailsActiveModel.currentDetails)
    }
    
    /// Convenient publisher for accessing default details properties by typed enum.
    /// - Returns: Publisher of default details properties.
    func getDefaultDetailsAccessorPublisher() -> AnyPublisher<DetailsAccessor, Never> {
        self.getDefaultDetails().$currentDetails.map(DetailsAccessor.init).eraseToAnyPublisher()
    }
}

// MARK: - Details Conversion to Blocks.
/// Deprecated.
///
/// Why?
///
/// Now we use view models that uses only blocks.
/// So, we have to convert our details to blocks first.
///
extension FileNamespace {
    /// Deprecated.
    private func convert(_ detailsActiveModel: DetailsActiveModel, of kind: DetailsContentKind) -> ActiveModel? {
        guard let rootId = self.rootId else {
            let logger = Logging.createLogger(category: .baseDocument)
            os_log(.debug, log: logger, "convert(_:of:). Our document is not ready yet.")
            return nil
        }
        
        let accessor = DetailsAccessor.init(value: detailsActiveModel.currentDetails)
        
        let block: BlockModelProtocol
        switch kind {
        case .title: block = TopLevel.AliasesMap.InformationUtilitiesDetailsBlockConverter.init(blockId: rootId)(.title(accessor.title ?? .init(value: "")))
        case .iconEmoji: block = TopLevel.AliasesMap.InformationUtilitiesDetailsBlockConverter.init(blockId: rootId)(.iconEmoji(accessor.iconEmoji ?? .init(value: "")))
        case .iconColor: block = TopLevel.AliasesMap.InformationUtilitiesDetailsBlockConverter.init(blockId: rootId)(.iconColor(accessor.iconColor ?? .init(value: "")))
        case .iconImage: block = TopLevel.AliasesMap.InformationUtilitiesDetailsBlockConverter.init(blockId: rootId)(.iconImage(accessor.iconImage ?? .init(value: "")))
        }
        
        if self.rootModel?.blocksContainer.get(by: block.information.id) != nil {
            let logger = Logging.createLogger(category: .baseDocument)
            os_log(.debug, log: logger, "convert(_:of:). We have already added details with id: %@", "\(block.information.id)")
        }
        else {
            self.rootModel?.blocksContainer.add(block)
        }
        
        return self.rootModel?.blocksContainer.choose(by: block.information.id)
    }
    
    func getDefaultDetailsActiveModel(of kind: DetailsContentKind) -> ActiveModel? {
        self.convert(self.defaultDetailsActiveModel, of: kind)
    }
}


// MARK: - Events
extension FileNamespace {
    typealias Events = EventListening.PackOfEvents
    
    /// Handle events initiated by user.
    ///
    /// - Parameter events: A pack of events.
    ///
    func handle(events: Events) {
        self.eventProcessor.handle(events: events)
    }
}
