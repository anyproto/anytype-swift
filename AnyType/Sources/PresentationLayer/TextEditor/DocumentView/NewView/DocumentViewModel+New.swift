//
//  DocumentViewModel+New.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 09.06.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os

fileprivate typealias Namespace = DocumentModule

private extension Logging.Categories {
    static let treeViewModel: Self = "DocumentModule.DocumentViewModel.Tree"
}

// MARK: State
extension Namespace.DocumentViewModel {
    enum State {
        case loading
        case empty
        case ready
    }
    var state: State {
        switch self.internalState {
        case .loading: return .loading
        default: return self.builders.isEmpty ? .empty : .ready
        }
    }
}

// MARK: Events
extension Namespace.DocumentViewModel {
    enum UserEvent {
        case pageDetailsViewModelsDidSet
    }
}

// MARK: - Options
extension Namespace.DocumentViewModel {
    /// Structure contains `Feature Flags`.
    ///
    struct Options {
        var shouldCreateEmptyBlockOnTapIfListIsEmpty: Bool = false
    }
}

extension DocumentModule {
    
    class DocumentViewModel: ObservableObject, Legacy_BlockViewBuildersProtocolHolder {
        typealias RootModel = BlocksModelsContainerModelProtocol
        
        typealias UserInteractionHandler = BlocksViews.NewSupplement.UserInteractionHandler
        
        /// Service
        private var blockActionsService: ServiceLayerNewModel.BlockActionsService = .init()
        
        /// Data Transformers
        private var transformer: BlocksModels.Transformer.FinalTransformer = .init()
        private var flattener: BlocksViews.NewSupplement.BlocksFlattener = .init()
        
        /// User Interaction Processor
        private var userInteractionHandler: UserInteractionHandler = .init()
        
        /// Combine Subscriptions
        private var subscriptions: Set<AnyCancellable> = .init()
        
        /// Builders Publisher
        private var buildersPublisherSubject: PassthroughSubject<AnyPublisher<BlocksViews.UserAction, Never>, Never> = .init()
        private var detailsPublisherSubject: PassthroughSubject<AnyPublisher<BlocksViews.UserAction, Never>, Never> = .init()
        lazy var userActionPublisher: AnyPublisher<AnyPublisher<BlocksViews.UserAction, Never>, Never> = {
            Publishers.Merge(self.buildersPublisherSubject, self.detailsPublisherSubject).eraseToAnyPublisher()
        }()
        private var buildersActionsPayloadsSubject: PassthroughSubject<AnyPublisher<BlocksViews.New.Base.ViewModel.ActionsPayload, Never>, Never> = .init()
        private lazy var buildersActionsPayloadsPublisher: AnyPublisher<AnyPublisher<BlocksViews.New.Base.ViewModel.ActionsPayload, Never>, Never> = {
            self.buildersActionsPayloadsSubject.eraseToAnyPublisher()
        }()
        private var buildersActionsPayloadsPublisherSubscription: AnyCancellable?
        
        /// Options property publisher.
        /// We expect that `ViewController` will listen this property.
        /// `ViewController` should sink on this property after `viewDidLoad`.
        ///
        @Published var options: Options = .init()
        
        @Published var error: String?
        @Published var rootModel: RootModel? {
            didSet {
                self.syncBuilders()
                self.configurePageDetails(for: self.rootModel)
                if let model = self.rootModel {
                    self.eventHandler?.didProcessEventsPublisher.sink(receiveValue: { [weak self] (value) in
                        self?.syncBuilders()
                    }).store(in: &self.subscriptions)
                    _ = self.eventHandler?.configured(model)
                }
            }
        }
        
        // MARK: - Events
        @Published var userEvent: UserEvent?
                
        private var eventHandler: EventHandler?
        
        // MARK: - Page View Models
        /// PageDetailsViewModel
        /// We use this model in BlocksViews for Title, Image.
        /// These models should subscribe on publishers of this model.
        /// Next, if we receive new data, we should pass this data directly to this model.
        /// All other models we handle in special
        @Published var wholePageDetailsViewModel: PageDetailsViewModel = .init()
        
        /// We  need this model to be Published cause need handle actions from IconEmojiBlock
        var pageDetailsViewModels: [BlockModels.Block.Information.Details.Kind : BlockViewBuilderProtocol] = [:] {
            didSet {
                self.userEvent = .pageDetailsViewModelsDidSet
                let values = self.pageDetailsViewModels.values.compactMap({$0 as? BlocksViews.Base.ViewModel}).map(\.userActionPublisher)
                self.detailsPublisherSubject.send(Publishers.MergeMany(values).eraseToAnyPublisher())
            }
        }
        
        // MARK: - Builders
        @Published var builders: [BlockViewBuilderProtocol] = []
        private var shouldClosePagePublisher: CurrentValueSubject<Bool, Error> = .init(false)
        private var internalState: State = .loading
        
        @Published var buildersRows: [Row] = [] {
            didSet {
                self.objectWillChange.send()
                
                let buildersModels = self.$buildersRows.map {
                    $0.compactMap({$0.builder as? BlocksViews.New.Base.ViewModel})
                }
                
                let buildersUserActionPublisher = buildersModels.flatMap({
                    Publishers.MergeMany($0.map(\.userActionPublisher))
                }).eraseToAnyPublisher()
                self.buildersPublisherSubject.send(buildersUserActionPublisher)
                
                let buildersActionsPayloadsPublisher = buildersModels.flatMap({
                    Publishers.MergeMany($0.map(\.actionsPayloadPublisher))
                }).eraseToAnyPublisher()
                
                self.buildersActionsPayloadsSubject.send(buildersActionsPayloadsPublisher)
            }
        }
        
        var anyFieldPublisher: AnyPublisher<String, Never> = .empty()
        var fileFieldPublisher: AnyPublisher<FileBlocksViews.Base.BlockViewModel.State?, Never> = .empty()
        
        // put into protocol?
        // var userActionsPublisher: AnyPublisher<UserAction>
        
        // MARK: Deinitialization
        deinit {
            self.close()
        }
        
        func setupSubscriptions() {
            self.buildersActionsPayloadsPublisherSubscription = self.buildersActionsPayloadsPublisher.sink { [weak self] (value) in
                _ = self?.userInteractionHandler.configured(value)
            }
        }
        
        // MARK: Initialization
        init(documentId: String?, options: Options) {
            // TODO: Add failable init.
            let logger = Logging.createLogger(category: .treeViewModel)
            os_log(.debug, log: logger, "Don't forget to change to failable init?()")
            
            guard let documentId = documentId else {
                let logger = Logging.createLogger(category: .treeViewModel)
                os_log(.debug, log: logger, "Don't pass nil documentId to DocumentViewModel.init()")
                return
            }
            
            self.setupSubscriptions()
            self.options = options
            _ = self.wholePageDetailsViewModel.configured(documentId: documentId)
            
            // Publishers
            self.userInteractionHandler.reactionPublisher.sink { [weak self] (value) in
                self?.process(reaction: value)
            }.store(in: &self.subscriptions)
            
            // We are waiting for value "true" to send `.blockClose()` with parameters "contextID: documentId, blockID: documentId"
            self.shouldClosePagePublisher.drop(while: {$0 == false}).flatMap { [weak self] (value) -> AnyPublisher<Never, Error> in
                self?.cleanupSubscriptions()
                return BlockActionsService.Close().action(contextID: documentId, blockID: documentId).eraseToAnyPublisher()
            }.sink(receiveCompletion: { _ in }, receiveValue: {_ in }).store(in: &self.subscriptions)
            
            self.obtainDocument(documentId: documentId)
            
            self.$builders.sink { [weak self] value in
                self?.buildersRows = value.compactMap(Row.init)
            }.store(in: &self.subscriptions)
            
            self.anyFieldPublisher = self.$builders
                .map {
                    $0.compactMap { $0 as? TextBlocksViews.Base.BlockViewModel }
            }
            .flatMap {
                Publishers.MergeMany($0.map{$0.textDidChangePublisher.map(\.string)})
            }
            .eraseToAnyPublisher()
            
            self.fileFieldPublisher = self.$builders
                .map {
                    $0.compactMap { $0 as? FileBlocksViews.Base.BlockViewModel }
            }.flatMap {
                Publishers.MergeMany($0.map{$0.$state})
            }.eraseToAnyPublisher()
        }
        
        /// Update @Published $builders.
        private func syncBuilders() {
            DispatchQueue.main.async {
                self.rootModel.flatMap(self.toList(_:)).flatMap(self.update(builders:))
            }
        }
        
        // TODO: Add caching?
        private func update(builders: [BlockViewBuilderProtocol]) {
            let difference = builders.difference(from: self.builders) { $0.blockId == $1.blockId }
            if let result = self.builders.applying(difference) {
                self.builders = result
            }
            else {
                // We should set all builders, because our collection is empty?
                self.builders = builders
            }
            //        self.builders = builders
        }
        
        /// Convert tree model to list view model.
        /// - Parameter model: a tree model that we want to convert.
        /// - Returns: a list of view models. ( builders )
        private func toList(_ model: RootModel) -> [BlockViewBuilderProtocol] {
            guard let rootId = model.rootId, let rootModel = model.choose(by: rootId) else { return [] }
            let result = flattener.toList(rootModel)
            // TODO: Add model logging.
            //            let logger = Logging.createLogger(category: .treeViewModel)
            //            os_log(.debug, log: logger, "model: %@", model.debugDescription)
            return result
        }
        
        /// Process blocks list when we receive it from event BlockShow.
        /// - Parameters:
        ///   - contextId: an Identifier of context in which we are working. It is equal to documentId.
        ///   - rootId: an Identifier of root block. It is equal to top-most `Page Identifier`.
        ///   - models: models is a `List` of Middleware objects ( actually, our model objects ) that we would like to process.
        private func processBlocks(contextId: String? = nil, rootId: String? = nil, models: [BlocksModelsInformationModelProtocol]) {
            // create metablock.
            
            guard let contextId = contextId, let rootId = rootId else {
                return
            }
            
            let baseModel = self.transformer.transform(models.map({BlocksModels.Aliases.Information.InformationModel.init(information: $0)}), rootId: rootId)
            
            _ = self.userInteractionHandler.configured(documentId: contextId)
                        
            let eventHandler = EventHandler.init()
            _ = eventHandler.configured(baseModel)
            
            self.eventHandler = eventHandler
            
            self.rootModel = baseModel
        }
        
        private func internalProcessBlocks(contextId: String? = nil, rootId: String? = nil, models: [BlocksModelsInformationModelProtocol]) {
            if self.internalState != .ready {
                self.processBlocks(contextId: contextId, rootId: rootId, models: models)
                self.internalState = .ready
            }
        }
        
        private func processMiddlewareEvents(contextId: String, messages: [Anytype_Event.Message]) {
            messages.filter({$0.value == .blockShow($0.blockShow)}).compactMap({ [weak self] value in
                self?.blockActionsService.eventListener.createFrom(event: value.blockShow)
            }).forEach({[weak self] value in
                self?.internalProcessBlocks(contextId: contextId, rootId: value.rootId, models: value.blocks)
            })
        }
        
        private func obtainDocument(documentId: String?) {
            guard let documentId = documentId else { return }
            self.internalState = .loading
            
            self.blockActionsService.open.action(contextID: documentId, blockID: documentId)
                .print()
                .receive(on: RunLoop.main)
                .sink(receiveCompletion: { [weak self] (value) in
                    switch value {
                    case .finished: break
                    case let .failure(error):
                        self?.internalState = .empty
                        self?.error = error.localizedDescription
                    }
                    }, receiveValue: { [weak self] value in
                        self?.processMiddlewareEvents(contextId: value.contextID, messages: value.messages)
                }).store(in: &self.subscriptions)
        }
    }
}

// MARK: Find Block
private extension Namespace.DocumentViewModel {
    func find(by blockId: String) -> BlocksViews.Base.ViewModel? {
        self.buildersRows.first { (row) in
            row.builder?.blockId == blockId
        }.map(\.builder).flatMap{$0 as? BlocksViews.Base.ViewModel}
    }
}

// MARK: Reactions
private extension Namespace.DocumentViewModel {
    func process(reaction: UserInteractionHandler.Reaction) {
        switch reaction {
        case let .focus(value):
            let payload = value.payload
            let position = value.position
            // find viewModelBuilder first.
            let viewModel = self.find(by: payload.blockId) as? TextBlocksViews.Base.BlockViewModel
            viewModel?.set(focus: true) // here we send .set(focus: Bool) to correct viewModel.
            switch position {
            case .beginning: return
            case .end: return
            case let .at(value): return
            default: return
            }
        case let .shouldOpenPage(value):
            // we should open this page.
            // so, tell view controller to open page, yes?..
            let blockId = value.payload.blockId
            // tell view controller to open page.
        
        case let .shouldHandleEvent(value):
            let events = value.payload.events.events.compactMap(\.value)
            self.eventHandler?.handle(events: events)
            
        default:
            return
        }
    }
}

// MARK: - PageDetails
private extension Namespace.DocumentViewModel {
    func configurePageDetails(for rootModel: RootModel?) {
        guard let model = rootModel else { return }
        guard let rootId = model.rootId, let ourModel = model.choose(by: rootId) else { return }
        
        /// take rootViewModel and configure pageDetails from this model.
        /// use special flattener for this.
        /// extract details and try to build view model for each detail.
        
        /// Do not delete this code.
        /// We may need it later when we determine what details are.
        //            let information = value.information
        //            let converter = BlockModels.Block.Information.DetailsAsBlockConverter(information: value.information)
        //            let blocks = information.details.toList().map(converter.callAsFunction(_:))
        
        /// sort details if you want, but for now we only have one detail: title.
        ///
        
        /// And create correct viewModels.
        ///
        
        // TODO: Refactor later.
        let blockModel = ourModel.blockModel
        let information = blockModel.information
        let details = information.pageDetails
        let title = details.title
        let emoji = details.iconEmoji
        
        /// Title Model
        let titleBlock = BlocksModels.Aliases.Information.DetailsAsBlockConverter(information: information)(.title(title ?? .init(text: "")))
        
        /// Emoji Model
        let emojiBlock = BlocksModels.Aliases.Information.DetailsAsBlockConverter(information: information)(.iconEmoji(emoji ?? .init(text: "")))
        
        /// Add entries to model.
        /// Well, it is cool that we store our details of page into one scope with all children.
        ///
        model.add(titleBlock)
        model.add(emojiBlock)
        
        if let titleModel = model.choose(by: titleBlock.information.id), let emojiModel = model.choose(by: emojiBlock.information.id) {
            let titleBlockModel = BlocksViews.New.Page.Title.ViewModel.init(titleModel).configured(pageDetailsViewModel: self.wholePageDetailsViewModel)
            
            let emojiBlockModel = BlocksViews.New.Page.IconEmoji.ViewModel.init(emojiModel).configured(pageDetailsViewModel: self.wholePageDetailsViewModel)
            
            
            // Now we have correct blockViewModels
            let models = [BlockModels.Block.Information.Details.Kind.iconEmoji : emojiBlockModel, BlockModels.Block.Information.Details.Kind.title : titleBlockModel]
            
            self.pageDetailsViewModels = models
            
            self.wholePageDetailsViewModel.receive(details: details)
            // Send event that we are ready.
        }
    }
}

// MARK: - Cleanup
extension Namespace.DocumentViewModel {
    func close() {
        self.closePage()
    }
}

private extension Namespace.DocumentViewModel {
    // It is called automatically ( should be called automatically ) by publisher
    
    func closePage() {
        self.shouldClosePagePublisher.send(true)
    }
    
    func cleanupSubscriptions() {
        self.subscriptions.cancelAll()
    }
}

// MARK: - On Tap Gesture
extension Namespace.DocumentViewModel {
    func handlingTapIfEmpty() {
        self.userInteractionHandler.createEmptyBlock(listIsEmpty: self.state == .empty)
    }
}

// MARK: - TableViewModelProtocol
extension Namespace.DocumentViewModel: TableViewModelProtocol {
    func numberOfSections() -> Int {
        1
    }
    
    func countOfElements(at: Int) -> Int {
        self.builders.count
    }
    
    func section(at: Int) -> Section {
        .init()
    }
    
    func element(at: IndexPath) -> Row {
        guard self.builders.indices.contains(at.row) else {
            return .init(builder: TextBlocksViews.Base.BlockViewModel.empty)
        }
        return .init(builder: self.builders[at.row])
    }
    
    struct Section {
        var section: Int = 0
        static var first: Section = .init()
        init() {}
    }
    
    struct Row {
        weak var builder: BlockViewBuilderProtocol?
        var indentationLevel: UInt {
            //            return 0
            (builder as? BlocksViews.Base.ViewModel).flatMap({$0.indentationLevel()}) ?? 0
        }
    }
}

// MARK: - TableViewModelProtocol.Section
extension Namespace.DocumentViewModel.Section: Hashable {}

// MARK: - TableViewModelProtocol.Row
extension Namespace.DocumentViewModel.Row: Hashable, Equatable {
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        //        lhs.builder.id == rhs.builder.id
        lhs.builder?.blockId == rhs.builder?.blockId
    }
    
    func hash(into hasher: inout Hasher) {
        //        hasher.combine(self.builder.id)
        hasher.combine(self.builder?.blockId)
    }
}

// MARK: didSelectItem
extension Namespace.DocumentViewModel {
    
    func didSelectBlock(at index: IndexPath) {
        let item = element(at: index)
        // dispatch event
        if let builder = item.builder as? BlocksViews.New.Base.ViewModel {
            builder.receive(event: .didSelectRowInTableView)
        }
    }
    
}

// MARK: Event Listening
extension Namespace.DocumentViewModel {
    class EventHandler: NewEventHandler {
        typealias Event = Anytype_Event.Message.OneOf_Value
        typealias ViewModel = DocumentModule.DocumentViewModel
        
        private var didProcessEventsSubject: PassthroughSubject<Void, Never> = .init()
        var didProcessEventsPublisher: AnyPublisher<Void, Never> = .empty()
        
        
        private typealias Builder = BlocksModels.Block.Builder
        private typealias Information = BlocksModels.Aliases.Information.InformationModel
        private typealias Updater = BlocksModels.Updater
        
        weak var container: BlocksModelsContainerModelProtocol?
        
        private var parser: BlocksModels.Parser = .init()
        private var updater: BlocksModels.Updater?
        
        init() {
            self.setup()
        }
        
        func setup() {
            self.didProcessEventsPublisher = self.didProcessEventsSubject.eraseToAnyPublisher()
        }
                
        func configured(_ container: BlocksModelsContainerModelProtocol) -> Self {
            self.updater = .init(container)
            self.container = container
            return self
        }
                
        func handleOneEvent(_ event: Anytype_Event.Message.OneOf_Value) {
            switch event {
            case let .blockAdd(value):
                value.blocks
                    .compactMap(self.parser.convert(block:))
                    .map(Information.init(information:))
                    .map({Builder.build(information:$0)})
                    .forEach { (value) in
                        self.updater?.insert(block: value)
                }
            
            case let .blockDelete(value):
                // Find blocks and remove them from map.
                // And from tree.
                value.blockIds.forEach({ (value) in
                    self.updater?.delete(at: value)
                })
            
            case let .blockSetChildrenIds(value):
                let parentId = value.id
                self.updater?.set(children: value.childrenIds, parent: parentId)
            
            default: return
            }
        }
        
        private func finalize() {
            guard let container = self.container else {
                let logger = Logging.createLogger(category: .treeViewModel)
                os_log(.debug, log: logger, "Container is nil in event handler. Something went wrong.")
                return
            }
            
            Builder.buildTree(container: container)
            // Notify about updates if needed.
            self.didProcessEventsSubject.send(())
        }
        
        func handle(events: [Anytype_Event.Message.OneOf_Value]) {
            _ = events.compactMap(self.handleOneEvent(_:))
            self.finalize()
        }
    }

}
