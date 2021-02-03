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
    func configureDetails(for container: RootModel?) {
        guard let container = container, let rootId = container.rootId, let ourModel = container.detailsContainer.choose(by: rootId) else {
            let logger = Logging.createLogger(category: .baseDocument)
            os_log(.debug, log: logger, "configureDetails(for:). Our document is not ready yet")
            return
        }
        let publisher = ourModel.didChangeInformationPublisher()
        self.defaultDetailsActiveModel.configured(publisher: publisher)
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
    func getModels() -> [ActiveModel] {
        guard let container = self.rootModel, let rootId = container.rootId, let activeModel = container.blocksContainer.choose(by: rootId) else {
            let logger = Logging.createLogger(category: .baseDocument)
            os_log(.debug, log: logger, "getModels. Our document is not ready yet")
            return []
        }
        return DocumentModule.Document.BaseFlattener.flatten(root: activeModel, in: container, options: .default)
    }
}

// MARK: - Publishers
extension FileNamespace {
    typealias ModelsUpdates = DocumentModule.EventProcessor.EventHandler.Update
    struct UpdateResult {
        var updates: ModelsUpdates
        var models: [ActiveModel]
    }
    
    private func updatePublisher() -> AnyPublisher<ModelsUpdates, Never> {
        self.eventProcessor.didProcessEventsPublisher
    }
    
    private func modelsPublisher() -> AnyPublisher<[ActiveModel], Never> {
        self.updatePublisher().map { [weak self] (value) in
            self?.getModels() ?? []
        }.eraseToAnyPublisher()
    }
    
    func modelsAndUpdatePublisher() -> AnyPublisher<UpdateResult, Never> {
        self.updatePublisher().map { [weak self] (value) in
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
    
    /// Convenient publisher for accessing details properties by typed enum.
    ///
    /// Note.
    ///
    /// You should assure yourself, that id should be in a list of details of opened document.
    ///
    /// - Parameter id: Id of item for which we would like to listen events.
    /// - Returns: Publisher of default details properties.
    func getDetailsAccessor(by id: DetailsId) -> AnyPublisher<DetailsAccessor, Never>? {
        self.getDetails(by: id)?.$currentDetails.safelyUnwrapOptionals().map(DetailsAccessor.init).eraseToAnyPublisher()
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
    
    /// Convenient publisher for accessing default details properties by typed enum.
    /// - Returns: Publisher of default details properties.
    func getDefaultDetailsAccessor() -> AnyPublisher<DetailsAccessor, Never> {
        self.getDefaultDetails().$currentDetails.safelyUnwrapOptionals().map(DetailsAccessor.init).eraseToAnyPublisher()
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
