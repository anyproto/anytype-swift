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
    static let documentViewModel: Self = "DocumentModule.DocumentViewModel"
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
        /// Aliases
        typealias RootModel = BlocksModelsContainerModelProtocol
        typealias BlockId = BlocksModels.Aliases.BlockId
        
        typealias UserInteractionHandler = BlocksViews.NewSupplement.UserInteractionHandler
        typealias ListUserInteractionHandler = BlocksViews.NewSupplement.ListUserInteractionHandler
        
        typealias BlocksUserAction = BlocksViews.UserAction
        
        typealias BlocksViewsNamespace = BlocksViews.New
        
        /// DocumentId
        private var debugDocumentId: String = ""
        
        /// Service
        private var blockActionsService: ServiceLayerModule.BlockActionsService = .init()
        
        /// Data Transformers
        private var transformer: BlocksModels.Transformer.FinalTransformer = .init()
        private var flattener: BlocksViews.NewSupplement.BlocksFlattener = .init()
        
        /// User Interaction Processor
        private var userInteractionHandler: UserInteractionHandler = .init()
        private var listUserInteractionHandler: ListUserInteractionHandler = .init()
        
        /// Combine Subscriptions
        private var subscriptions: Set<AnyCancellable> = .init()
        
        /// Selection Handler
        private(set) var selectionHandler: DocumentModuleSelectionHandlerProtocol?
        
        /// Builders Publisher
        /// It is incorrect stuff.
        /// Please, use a little passthrough subjects, OK?
        /// Deprecated Publishers and Subjects
        private var buildersPublisherSubject: PassthroughSubject<AnyPublisher<BlocksUserAction, Never>, Never> = .init()
        private var detailsPublisherSubject: PassthroughSubject<AnyPublisher<BlocksUserAction, Never>, Never> = .init()
        
        private var buildersActionsPayloadsSubject: PassthroughSubject<AnyPublisher<BlocksViewsNamespace.Base.ViewModel.ActionsPayload, Never>, Never> = .init()
        private lazy var buildersActionsPayloadsPublisher: AnyPublisher<AnyPublisher<BlocksViewsNamespace.Base.ViewModel.ActionsPayload, Never>, Never> = { self.buildersActionsPayloadsSubject.eraseToAnyPublisher() }()
        
        private var listToolbarSubject: PassthroughSubject<BlocksViews.Toolbar.UnderlyingAction, Never> = .init()
        
        /// Deprecated
        private var listSubject: PassthroughSubject<BlocksUserAction, Never> = .init()
        
        private var publicUserActionSubject: PassthroughSubject<BlocksUserAction, Never> = .init()
        lazy var publicUserActionPublisher: AnyPublisher<BlocksUserAction, Never> = { self.publicUserActionSubject.eraseToAnyPublisher() }()
        
        private var publicActionsPayloadSubject: PassthroughSubject<BlocksViewsNamespace.Base.ViewModel.ActionsPayload, Never> = .init()
        lazy var publicActionsPayloadPublisher: AnyPublisher<BlocksViewsNamespace.Base.ViewModel.ActionsPayload, Never> = { self.publicActionsPayloadSubject.eraseToAnyPublisher() }()
        
        /// Deprecated
        lazy private var listPublisherSubject: CurrentValueSubject<AnyPublisher<BlocksUserAction, Never>, Never> = { .init(self.listSubject.eraseToAnyPublisher()) }()
        private var listActionsPayloadSubject: PassthroughSubject<ActionsPayload, Never> = .init()
        lazy private var listActionsPayloadPublisher: AnyPublisher<ActionsPayload, Never> = {
            self.listActionsPayloadSubject.eraseToAnyPublisher()
        }()
                
        lazy var soloUserActionPublisher: AnyPublisher<BlocksUserAction, Never> = {
            /// As soon as we made another curve in learning publishers
            /// It is pretty simple to achieve our desired behavior without publishers of publishers.
            /// We still will provide appropriate methods to support backward compatibility.
            /// But it is unnecessary.
            ///
            /// What is going on here?
            ///
            /// We take latest values of three publishers, several of them ( builders and details ) could change in time if builders or details are updated.
            ///
            /// 1. Take builders, details and list ( whole model here ) publishers of publishers.
            /// 2. Combine their latest values.
            ///
            /// -- Stop for a bit for a note --
            /// If you update ANY publisher by sending any new value in it, all latest values of counterpart publishers will be used.
            ///
            /// Look at it:
            ///
            /// f: ([[]]) -> ([(_,_,_)])
            /// [[A], [B], [C]] -> ([(A, B, C)])
            ///
            /// [[A, D], [B], [C]] -> ([(D, B, C)])
            ///
            /// -- End stop --
            /// 3. Merge all values into one publisher or into one value.
            /// 4. Erase.
            ///
            /// At step 3 we just merge values into one publisher, so, any value of triple here could emit value.
            ///
            let buildersSubject = self.buildersPublisherSubject
            let detailsSubject = self.detailsPublisherSubject
            let listSubject = self.listPublisherSubject
            let first = buildersSubject
                //Publishers.MakeConnectable(upstream: buildersSubject).autoconnect()
            let second = detailsSubject
                //Publishers.MakeConnectable(upstream: detailsSubject).autoconnect()
            let third = listSubject
            
            return Publishers.CombineLatest3(first, second, third).flatMap { (value) -> AnyPublisher<BlocksUserAction, Never> in
                Publishers.Merge3(value.0, value.1, value.2).eraseToAnyPublisher()
            }.handleEvents(receiveSubscription: { [weak self] value in
                self?.refreshUserActionsAndPayloadsAndDetails()
            }, receiveOutput: nil, receiveCompletion: nil, receiveCancel: nil, receiveRequest: { [weak self] value in
                self?.refreshUserActionsAndPayloadsAndDetails()
            }).eraseToAnyPublisher()
        }()
        lazy var userActionPublisher: AnyPublisher<AnyPublisher<BlocksUserAction, Never>, Never> = {
            /// For now, we just collect three publishers and merge them as one publisher.
            /// If we change current value of our publisher ( list Publisher Subject ), it would go on top of stream of publishers.
            /// In this case we would receive value.
            ///
            /// [A, B, C] // Stream of events
            /// [[A, A, A], [B, B], C] // Stream of Publishers
            /// [A, B, C, A, A, A, B, B, A, A] // Stream of Merged Publishers.
            /// As you see, you can't put C on top of stream, because it is `CurrentValueSubject`.
            ///
//            return Publishers.Merge3(self.buildersPublisherSubject, self.detailsPublisherSubject, self.listPublisherSubject).eraseToAnyPublisher()
//            Publishers.CombineLatest3(self.buildersPublisherSubject, self.detailsPublisherSubject, self.listPublisherSubject)
            
            let first = self.buildersPublisherSubject
            let second = self.detailsPublisherSubject
            let third = self.listPublisherSubject
            
            return Publishers.CombineLatest3(first, second, third).map({ value -> AnyPublisher<BlocksUserAction, Never> in
                Publishers.Merge3(value.0, value.1, value.2).eraseToAnyPublisher()
            }).handleEvents(receiveSubscription: { [weak self] value in
                self?.refreshUserActionsAndPayloadsAndDetails()
            }, receiveOutput: nil, receiveCompletion: nil, receiveCancel: nil, receiveRequest: { [weak self] value in
                self?.refreshUserActionsAndPayloadsAndDetails()
            }).eraseToAnyPublisher()
//            Just(self.soloUserActionPublisher).eraseToAnyPublisher()
        }()
        
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
                        self?.syncBuilders {
                            switch value {
                            case .general: break
                            case let .update(value):
                                if !value.updatedIds.isEmpty {
                                    self?.anyStyleSubject.send(value.updatedIds)
                                }
                                if !value.deletedIds.isEmpty {
                                    value.deletedIds.forEach { (value) in
                                        self?.toggle(value)
                                    }
                                }
                            }
                        }
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
        typealias PageDetailsViewModelsDictionary = [BlocksModels.Aliases.Information.PageDetails.Details.Kind : BlockViewBuilderProtocol]
        var pageDetailsViewModels: PageDetailsViewModelsDictionary = [:] {
            didSet {
                self.userEvent = .pageDetailsViewModelsDidSet
//                self.refreshDetails(self.pageDetailsViewModels)
                self.enhanceDetails(self.pageDetailsViewModels)
            }
        }
        
        // MARK: - Builders
        @Published var builders: [BlockViewBuilderProtocol] = []
        private var shouldClosePagePublisher: CurrentValueSubject<Bool, Error> = .init(false)
        private var internalState: State = .loading
        
        @Published var buildersRows: [Row] = [] {
            didSet {
                self.objectWillChange.send()
                                
                /// Disable selection mode.
                if self.buildersRows.isEmpty {
                    self.set(selectionEnabled: false)
                }
            }
        }
                        
        var anyFieldPublisher: AnyPublisher<String, Never> = .empty()
        var fileFieldPublisher: AnyPublisher<BlocksViewsNamespace.File.Image.ViewModel.State?, Never> = .empty()
        
        /// We should update some items in place.
        /// For that, we use this subject which send events that some items are just updated, not removed or deleted.
        /// Its `Output` is a `List<BlockId>`
        private var anyStyleSubject: PassthroughSubject<[BlockId], Never> = .init()
        var anyStylePublisher: AnyPublisher<[BlockId], Never> = .empty()
        
        // put into protocol?
        // var userActionsPublisher: AnyPublisher<UserAction>
        
        // MARK: Deinitialization
        deinit {
            self.close()
        }
        
        func setupSubscriptions() {
//            self.buildersActionsPayloadsPublisher.sink { [weak self] (value) in
//                _ = self?.userInteractionHandler.configured(value)
//            }.store(in: &self.subscriptions)
//
//            self.buildersActionsPayloadsPublisher.flatMap { (value) in
//                value
//            }.sink { [weak self] (value) in
//                self?.process(actionsPayload: value)
//            }.store(in: &self.subscriptions)
            
            self.publicActionsPayloadPublisher.sink { [weak self] (value) in
                self?.process(actionsPayload: value)
            }.store(in: &self.subscriptions)
            
            _ = self.userInteractionHandler.configured(self.publicActionsPayloadPublisher)
            
            self.listToolbarSubject.sink { [weak self] (value) in
                self?.process(toolbarAction: value)
            }.store(in: &self.subscriptions)
            
            _ = self.listUserInteractionHandler.configured(self.listActionsPayloadPublisher)
        }
        
        // MARK: Initialization
        init(documentId: String?, options: Options) {
            // TODO: Add failable init.
            let logger = Logging.createLogger(category: .documentViewModel)
            os_log(.debug, log: logger, "Don't forget to change to failable init?()")
            
            guard let documentId = documentId else {
                let logger = Logging.createLogger(category: .documentViewModel)
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
            
            self.listUserInteractionHandler.reactionPublisher.sink { [weak self] (value) in
                self?.process(reaction: value)
            }.store(in: &self.subscriptions)
            
            // We are waiting for value "true" to send `.blockClose()` with parameters "contextID: documentId, blockID: documentId"
            self.shouldClosePagePublisher.drop(while: {$0 == false}).flatMap { [weak self] (value) -> AnyPublisher<Never, Error> in
                self?.cleanupSubscriptions()
                return BlockActionsService.Close().action(contextID: documentId, blockID: documentId).eraseToAnyPublisher()
            }.sink(receiveCompletion: { _ in }, receiveValue: {_ in }).store(in: &self.subscriptions)
            
            self.obtainDocument(documentId: documentId)
                        
            self.$builders.sink { [weak self] value in
                self?.buildersRows = value.compactMap(Row.init).map({ (value) in
                    var value = value
                    return value.configured(selectionHandler: self?.selectionHandler)
                })
//                self?.refreshUserActionsAndPayloads(value)
                self?.enhanceUserActionsAndPayloads(value)
            }.store(in: &self.subscriptions)
            
            self.anyFieldPublisher = self.$builders
                .map {
                    $0.compactMap { $0 as? BlocksViewsNamespace.Text.Base.ViewModel }
            }
            .flatMap {
                Publishers.MergeMany($0.map{$0.textDidChangePublisher.map(\.string)})
            }
            .eraseToAnyPublisher()
            
            self.fileFieldPublisher = self.$builders
                .map {
                    $0.compactMap { $0 as? BlocksViewsNamespace.File.Image.ViewModel }
            }.flatMap {
                Publishers.MergeMany($0.map{$0.$state})
            }.eraseToAnyPublisher()
            
            self.anyStylePublisher = self.anyStyleSubject.eraseToAnyPublisher()
        }
        
        /// Update @Published $builders.
        private func syncBuilders(_ completion: @escaping () -> () = { }) {
            DispatchQueue.main.async {
                self.rootModel.flatMap(self.toList(_:)).flatMap(self.update(builders:))
                completion()
            }
        }
        
        // TODO: Add caching?
        private func update(builders: [BlockViewBuilderProtocol]) {
            /// We should add caching, otherwise, we will miss updates from long-playing views as file uploading or downloading views.
            let difference = builders.difference(from: self.builders) {$0.diffable == $1.diffable}
            if let result = self.builders.applying(difference) {
                self.builders = result
            }
            else {
                // We should set all builders, because our collection is empty?
                self.builders = builders
            }
//            self.builders = builders
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
            _ = self.listUserInteractionHandler.configured(documentId: contextId)
                        
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
            
            self.debugDocumentId = documentId
            
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

// MARK: Reactions
private extension Namespace.DocumentViewModel {
    func process(reaction: UserInteractionHandler.Reaction) {
        switch reaction {
        case let .shouldHandleEvent(value):
            let events = value.payload.events
            self.eventHandler?.handle(events: events)
            
        default:
            return
        }
    }
    func process(reaction: ListUserInteractionHandler.Reaction) {
        switch reaction {
        case let .shouldHandleEvent(value):
            let events = value.payload.events
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
            let titleBlockModel = BlocksViewsNamespace.Page.Title.ViewModel.init(titleModel).configured(pageDetailsViewModel: self.wholePageDetailsViewModel)
            
            let emojiBlockModel = BlocksViewsNamespace.Page.IconEmoji.ViewModel.init(emojiModel).configured(pageDetailsViewModel: self.wholePageDetailsViewModel)
            
            
            // Now we have correct blockViewModels
            
            self.pageDetailsViewModels = [
                .title : titleBlockModel,
                .iconEmoji : emojiBlockModel
            ]
            
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
        var row = Row.init(builder: self.builders[at.row])
        _ = row.configured(selectionHandler: self.selectionHandler)
        return row
    }
    
    struct Section {
        var section: Int = 0
        static var first: Section = .init()
        init() {}
    }
    
    struct Row {
        /// Soo.... We can't keep model in it.
        /// We should add information as structure ( which is immutable )
        /// And use it as presentation structure for cell.
        weak var builder: BlockViewBuilderProtocol?
        weak var selectionHandler: DocumentModuleSelectionHandlerCellProtocol?
        var information: BlocksModelsInformationModelProtocol?
        init(builder: BlockViewBuilderProtocol?) {
            self.builder = builder
            self.information = (self.builder as? BlocksViewsNamespace.Base.ViewModel)?.getBlock().blockModel.information
        }
        
        struct CachedDiffable: Hashable {
            var selected: Bool = false
            mutating func set(selected: Bool) {
                self.selected = selected
            }
        }
        
        var cachedDiffable: CachedDiffable = .init()
        
        var blockBuilder: BlocksViews.New.Base.ViewModel? {
            self.builder as? BlocksViewsNamespace.Base.ViewModel
        }
        var isPendingFirstResponder: Bool {
            self.blockBuilder?.getBlock().isFirstResponder ?? false
        }
        func resolvePendingFirstResponder() {
            if let model = self.blockBuilder?.getBlock() {
                BlocksModels.Utilities.FirstResponderResolver.resolvePendingUpdate(model)
            }
        }
    }
}

// MARK: - TableViewModelProtocol.Row / Configurations
extension Namespace.DocumentViewModel.Row {
    mutating func configured(selectionHandler: DocumentModuleSelectionHandlerCellProtocol?) -> Self {
        self.selectionHandler = selectionHandler
        self.cachedDiffable = .init(selected: self.isSelected)
        return self
    }
}

// MARK: - TableViewModelProtocol.Row / Indentation level
extension Namespace.DocumentViewModel.Row {
    typealias BlocksViewsNamespace = BlocksViews.New
    var indentationLevel: UInt {
        (self.builder as? BlocksViewsNamespace.Base.ViewModel).flatMap({$0.indentationLevel()}) ?? 0
    }
}

// MARK: - TableViewModelProtocol.Row / Rebuilding and Diffable
extension Namespace.DocumentViewModel.Row {
    func rebuilded() -> Self {
        .init(builder: self.builder)
    }
    func diffable() -> AnyHashable? {
//        if let builder = self.builder as? BlocksViewsNamespace.Base.ViewModel {
//            let diffable = self.information?.diffable()
//            let allEntries = [
//                "isFirstResponder": builder.getBlock().isFirstResponder,
//                "informationDiffable": diffable
//            ]
//            return .init(allEntries)
//        }
        return self.information?.diffable()
    }
}

// MARK: - TableViewModelProtocol.Row / Selection
extension Namespace.DocumentViewModel.Row: DocumentModuleSelectionCellProtocol {
    func getSelectionKey() -> BlockId? {
        (self.builder as? BlocksViewsNamespace.Base.ViewModel)?.getBlock().blockModel.information.id
    }
}


// MARK: - TableViewModelProtocol.Section
extension Namespace.DocumentViewModel.Section: Hashable {}

// MARK: - TableViewModelProtocol.Row

/// Well, we could compare buildersRows by their diffables...
/// But for now it is fine for us to keep simple equations.
///
/// NOTES: Why we could compare `diffables`.
/// As soon as we use `Row` as `DataModel` for a `shared` view model `builder`
/// we should keep a track of `initial` state of Rows.
/// We do it by providing `information` propepty, which is initiated in `init()`.
/// Treat this property as `fingerprint` of `initial` builder value.
///
///
extension Namespace.DocumentViewModel.Row: Hashable, Equatable {
    static private func sameKind(_ lhs: Self?, _ rhs: Self?) -> Bool {
        lhs?.information?.content.deepKind == rhs?.information?.content.deepKind
    }
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.builder?.blockId == rhs.builder?.blockId && lhs.cachedDiffable == rhs.cachedDiffable && sameKind(lhs, rhs)
//        lhs.diffable() == rhs.diffable() && lhs.cachedDiffable == rhs.cachedDiffable
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.builder?.blockId ?? "")
//        hasher.combine(self.diffable())
    }
}

// MARK: didSelectItem
extension Namespace.DocumentViewModel {
    
    func didSelectBlock(at index: IndexPath) {
        // dispatch event
        
        if self.selectionEnabled() {
            self.didSelect(atIndex: index)
            return
        }
        
        if let builder = element(at: index).builder as? BlocksViewsNamespace.Base.ViewModel {
            builder.receive(event: .didSelectRowInTableView)
        }
    }
    
}

// MARK: Selection Handling
private extension Namespace.DocumentViewModel {
    func process(actionsPayload: BlocksViewsNamespace.Base.ViewModel.ActionsPayload) {
        switch actionsPayload {
        case let .textView(value):
            switch value.action {
            case .textView(.showMultiActionMenuAction(.showMultiActionMenu)):
                self.set(selectionEnabled: true)
            default: return
            }
        default: return
        }
    }
    func didSelect(atIndex: IndexPath) {
        let item = element(at: atIndex)
        // so, we have to toggle item at index.
        let newValue = !item.isSelected
        if let key = item.getSelectionKey() {
            self.set(selected: newValue, id: key)
            // TODO: We should subscribe on updates in our cells and update them.
            /// For now we use `reloadData`
            self.syncBuilders()
        }
    }
    func process(_ value: DocumentModule.Selection.ToolbarPresenter.SelectionAction) {
        switch value {
        case let .selection(value):
            switch value {
            case let .selectAll(value):
                switch value {
                case .selectAll:
                    self.selectAll()
                    self.syncBuilders()
                case .deselectAll:
                    self.deselectAll()
                    self.syncBuilders()
                }
            case .done(.done):
                self.set(selectionEnabled: false)
                self.syncBuilders()
            }
        case let .toolbar(value):
            let selectedIds = self.list()
            switch value {
            case .turnInto: self.publicUserActionSubject.send(.toolbars(.turnIntoBlock(.init(output: self.listToolbarSubject))))
            case .delete: self.listActionsPayloadSubject.send(.toolbar(.init(model: selectedIds, action: .editBlock(.delete))))
            case .copy: break
            default: break
            }
        }
    }
    func process(toolbarAction: BlocksViews.Toolbar.UnderlyingAction) {
        let selectedIds = self.list()
        self.listActionsPayloadSubject.send(.toolbar(.init(model: selectedIds, action: toolbarAction)))
    }
}

extension Namespace.DocumentViewModel {
    enum ActionsPayload {
        typealias BlockId = BlocksModels.Aliases.BlockId
        typealias ListModel = [BlockId]
        struct Toolbar {
            typealias Model = ListModel
            typealias Action = BlocksViews.Toolbar.UnderlyingAction
            var model: Model
            var action: Action
        }
        
        case toolbar(Toolbar)
    }
}

extension Namespace.DocumentViewModel {
    func configured(multiSelectionUserActionPublisher: AnyPublisher<DocumentModule.Selection.ToolbarPresenter.SelectionAction, Never>) -> Self {
        multiSelectionUserActionPublisher.sink { [weak self] (value) in
            self?.process(value)
        }.store(in: &self.subscriptions)
        return self
    }
    func configured(selectionHandler: DocumentModuleSelectionHandlerProtocol?) -> Self {
        self.selectionHandler = selectionHandler
        return self
    }
}

// MARK: Debug
extension Namespace.DocumentViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(self.debugDocumentId)"
    }
}

// MARK: Enhance UserActions and Payloads
extension Namespace.DocumentViewModel {
    func enhanceUserActionsAndPayloads(_ builders: [BlockViewBuilderProtocol]) {
        let ourViewModels = builders.compactMap({$0 as? BlocksViewsNamespace.Base.ViewModel})
        
        _ = ourViewModels.map({$0.configured(userActionSubject: self.publicUserActionSubject)})
        
        _ = ourViewModels.map({$0.configured(actionsPayloadSubject: self.publicActionsPayloadSubject)})
    }
    
    func enhanceDetails(_ value: PageDetailsViewModelsDictionary) {
        _ = value.values.compactMap({$0 as? BlocksViewsNamespace.Base.ViewModel}).map({$0.configured(userActionSubject: self.publicUserActionSubject)})
    }
}

// MARK: Refresh UserActions and Payloads
extension Namespace.DocumentViewModel {
    func refreshUserActionsAndPayloadsAndDetails() {
        self.refreshUserActionsAndPayloads()
        self.refreshDetails()
    }
    func refreshDetails() {
        self.refreshDetails(self.pageDetailsViewModels)
    }
    func refreshDetails(_ value: PageDetailsViewModelsDictionary) {
        let values = value.values.compactMap({$0 as? BlocksViewsNamespace.Base.ViewModel}).map(\.userActionPublisher)
        self.detailsPublisherSubject.send(Publishers.MergeMany(values).eraseToAnyPublisher())
    }
    func refreshUserActionsAndPayloads() {
        self.refreshUserActionsAndPayloads(self.builders)
    }
    func refreshUserActionsAndPayloads(_ builders: [BlockViewBuilderProtocol]) {
        let ourViewModels = builders.compactMap({$0 as? BlocksViewsNamespace.Base.ViewModel})
        
        let userActions = ourViewModels.map(\.userActionPublisher)
        
        self.buildersPublisherSubject.send(Publishers.MergeMany(userActions).eraseToAnyPublisher())
        
        let actionsPayloads = ourViewModels.map(\.actionsPayloadPublisher)
        self.buildersActionsPayloadsSubject.send(Publishers.MergeMany(actionsPayloads).eraseToAnyPublisher())
    }
}
