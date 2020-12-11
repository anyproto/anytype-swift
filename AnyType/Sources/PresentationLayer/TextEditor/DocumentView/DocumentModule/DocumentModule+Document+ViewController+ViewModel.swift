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
import BlocksModels

fileprivate typealias Namespace = DocumentModule.Document.ViewController

private extension Logging.Categories {
    static let documentViewModel: Self = "DocumentModule.DocumentViewModel"
}

// MARK: State
extension Namespace.ViewModel {
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
extension Namespace.ViewModel {
    enum UserEvent {
        case pageDetailsViewModelsDidSet
    }
}

// MARK: - Options
extension Namespace.ViewModel {
    /// Structure contains `Feature Flags`.
    ///
    struct Options {
        var shouldCreateEmptyBlockOnTapIfListIsEmpty: Bool = false
    }
}

extension Namespace {
    
    class ViewModel: ObservableObject {
        /// Aliases
        typealias RootModel = TopLevelContainerModelProtocol
        typealias BlockId = TopLevel.AliasesMap.BlockId
        typealias ModelInformation = BlockInformationModelProtocol
        
        typealias Transformer = TopLevel.AliasesMap.BlockTools.Transformer.FinalTransformer
        
        typealias UserInteractionHandler = BlocksViews.NewSupplement.UserInteractionHandler
        typealias ListUserInteractionHandler = BlocksViews.NewSupplement.ListUserInteractionHandler
        
        typealias BlocksUserAction = BlocksViews.UserAction
        
        typealias BlocksViewsNamespace = BlocksViews.New
        
        /// DocumentId
        private var debugDocumentId: String = ""
        
        /// Service
        private var blockActionsService: ServiceLayerModule.Single.BlockActionsService = .init()
        
        /// Data Transformers
        private var transformer: Transformer = .defaultValue
        private var flattener: BlocksViews.NewSupplement.BaseFlattener = BlocksViews.NewSupplement.CompoundFlattener.init()
        
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
        
        private var publicSizeDidChangeSubject: PassthroughSubject<CGSize, Never> = .init()
        public private(set) lazy var publicSizeDidChangePublisher: AnyPublisher<CGSize, Never> = { self.publicSizeDidChangeSubject.eraseToAnyPublisher() }()
        
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
        }()
        
        /// Options property publisher.
        /// We expect that `ViewController` will listen this property.
        /// `ViewController` should sink on this property after `viewDidLoad`.
        ///
        @Published var options: Options = .init()
        
        @Published var error: String?
        @Published var rootModel: RootModel? {
            didSet {
                if let model = self.rootModel {
                    self.eventProcessor.didProcessEventsPublisher.sink(receiveValue: { [weak self] (value) in
                        switch value {
                        case .update(.empty): return
                        default: break
                        }
                        
                        self?.syncBuilders {
                            switch value {
                            case .general: break
                            case let .update(value):
                                /// We should calculate updates correctly.
                                /// For example, we should remove items if they appear in detetedIds.
                                /// That means that even if they appear in updatedIds, we still need to remove them.
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
                    _ = self.eventProcessor.configured(model)
                }
                _ = self.flattener.configured(self.rootModel)
                self.syncBuilders()
                self.configurePageDetails(for: self.rootModel)
            }
        }
        
        // MARK: - Events
        @Published var userEvent: UserEvent?
        private var eventProcessor: EventProcessor = .init()
        
        // MARK: - Page View Models
        /// PageDetailsViewModel
        /// We use this model in BlocksViews for Title, Image.
        /// These models should subscribe on publishers of this model.
        /// Next, if we receive new data, we should pass this data directly to this model.
        /// All other models we handle in special
        @Published var wholePageDetailsViewModel: PageDetailsViewModel = .init()
        
        /// We  need this model to be Published cause need handle actions from IconEmojiBlock
        typealias PageDetailsViewModelsDictionary = [TopLevel.AliasesMap.DetailsContent.Kind : BlockViewBuilderProtocol]
        var pageDetailsViewModels: PageDetailsViewModelsDictionary = [:] {
            didSet {
                self.enhanceDetails(self.pageDetailsViewModels)
                self.userEvent = .pageDetailsViewModelsDidSet
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
        
        /// Deprecated. Replaced by `publicSizeDidChangePublisher`
        @available(iOS, introduced: 13.0, deprecated: 14.0, renamed: "publicSizeDidChangePublisher")
        lazy var anyFieldPublisher: AnyPublisher<String, Never> = .empty()
        
        /// We could delete this publisher, lol.
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
                
                return ServiceLayerModule.Single.BlockActionsService.Close().action(contextID: documentId, blockID: documentId).eraseToAnyPublisher()
            }.sink(receiveCompletion: { _ in }, receiveValue: {_ in }).store(in: &self.subscriptions)
            
            self.obtainDocument(documentId: documentId)
                        
            self.$builders.sink { [weak self] value in
                self?.buildersRows = value.compactMap(Row.init).map({ (value) in
                    var value = value
                    return value.configured(selectionHandler: self?.selectionHandler)
                })
                self?.enhanceUserActionsAndPayloads(value)
            }.store(in: &self.subscriptions)
            
            // TODO: Deprecated.
            // It should be either removed or deleted.
            // We still (!) need this item to recalculate the size of text views on typing.
            // But, we should do it in the same manner as in other publishers:
            // We shouldn't merge them, we should have one passthrough subject which will be passed among all necessary views.
            //
            self.anyFieldPublisher = self.$builders
                .map {
                    $0.compactMap { $0 as? BlocksViewsNamespace.Text.Base.ViewModel }
            }
            .flatMap {
                Publishers.MergeMany($0.map{$0.textDidChangePublisher.map(\.string)})
            }
            .eraseToAnyPublisher()
            
            // TODO: Deprecated.
            // Remove it when you subscribe in view model on state of a model.
            self.fileFieldPublisher = self.$builders
                .map {
                    $0.compactMap { $0 as? BlocksViewsNamespace.File.Image.ViewModel }
            }.flatMap {
                Publishers.MergeMany($0.map{$0.$state})
            }.eraseToAnyPublisher()
            
            // TODO: Deprecated.
            // We should rename it.
            // Our case would be the following
            // We should expose one publisher that will publish different updates (delete/update/add) to outer world.
            // Or to our view controller.
            // Maybe it will publish only resulted collection of elements.
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
            guard let rootId = model.rootId, let rootModel = model.blocksContainer.choose(by: rootId) else { return [] }
            let result = self.flattener.toList(rootModel)
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
        private func processBlocks(contextId: String? = nil, rootId: String? = nil, models: [BlocksModelsModule.Parser.PageEvent]) {
            // create metablock.
            
            guard let contextId = contextId, let rootId = rootId else {
                return
            }
            
            guard let event = models.first else {
                return
            }
            
            let blocksContainer = self.transformer.transform(event.blocks, rootId: rootId)
            let parsedDetails = event.details.map(TopLevel.Builder.detailsBuilder.build(information:))
            let detailsContainer = TopLevel.Builder.detailsBuilder.build(list: parsedDetails)
            
            _ = self.userInteractionHandler.configured(documentId: contextId)
            _ = self.listUserInteractionHandler.configured(documentId: contextId)
            
            
            /// Add details models to process.
            self.rootModel = TopLevel.Builder.build(rootId: rootId, blockContainer: blocksContainer, detailsContainer: detailsContainer)
        }
        
        private func internalProcessBlocks(contextId: String? = nil, rootId: String? = nil, models: [BlocksModelsModule.Parser.PageEvent]) {
            if self.internalState != .ready {
                self.processBlocks(contextId: contextId, rootId: rootId, models: models)
                self.internalState = .ready
            }
        }
        
        private func processMiddlewareEvents(contextId: String, messages: [Anytype_Event.Message]) {
            /// For now we just assuming that we have only one blockShow.
            let blockShow = messages.filter({$0.value == .blockShow($0.blockShow)}).first?.blockShow
            let models = self.eventProcessor.handleBlockShow(events: .init(contextId: contextId, events: messages, ourEvents: []))
            self.internalProcessBlocks(contextId: contextId, rootId: blockShow?.rootID, models: models)
        }
        
        private func obtainDocument(documentId: String?) {
            guard let documentId = documentId else { return }
            self.internalState = .loading
            
            self.debugDocumentId = documentId
            
            self.blockActionsService.open.action(contextID: documentId, blockID: documentId)
//                .print()
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
private extension Namespace.ViewModel {
    func process(reaction: UserInteractionHandler.Reaction) {
        switch reaction {
        case let .shouldHandleEvent(value):
            let events = value.payload.events
            self.eventProcessor.handle(events: events)
            
        default:
            return
        }
    }
    func process(reaction: ListUserInteractionHandler.Reaction) {
        switch reaction {
        case let .shouldHandleEvent(value):
            let events = value.payload.events
            self.eventProcessor.handle(events: events)
            
        default:
            return
        }
    }
}

// MARK: - PageDetails
private extension Namespace.ViewModel {
    func configurePageDetails(for rootModel: RootModel?) {
        guard let model = rootModel else { return }
        // TODO: Revert back when you are ready.
        guard let rootId = model.rootId, let ourModel = model.detailsContainer.choose(by: rootId) else { return }
        
        let detailsPublisher = ourModel.didChangeInformationPublisher()
        self.wholePageDetailsViewModel.configured(publisher: detailsPublisher)

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
        let blockModel = ourModel.detailsModel
        let information = blockModel.details
        
        let details = TopLevel.AliasesMap.DetailsUtilities.InformationAccessor(value: information)        
        
        let title = details.title
        let emoji = details.iconEmoji
        
        /// Title Model
        let titleBlock = TopLevel.AliasesMap.InformationUtilitiesDetailsBlockConverter.init(blockId: rootId)(.title(title ?? .init(value: "")))

        /// Emoji Model
        let emojiBlock = TopLevel.AliasesMap.InformationUtilitiesDetailsBlockConverter.init(blockId: rootId)(.iconEmoji(emoji ?? .init(value: "")))

        /// Add entries to model.
        /// Well, it is cool that we store our details of page into one scope with all children.
        ///
        model.blocksContainer.add(titleBlock)
        model.blocksContainer.add(emojiBlock)

        if let titleModel = model.blocksContainer.choose(by: titleBlock.information.id), let emojiModel = model.blocksContainer.choose(by: emojiBlock.information.id) {
            let titleBlockModel = BlocksViewsNamespace.Page.Title.ViewModel.init(titleModel).configured(pageDetailsViewModel: self.wholePageDetailsViewModel)

            let emojiBlockModel = BlocksViewsNamespace.Page.IconEmoji.ViewModel.init(emojiModel).configured(pageDetailsViewModel: self.wholePageDetailsViewModel)


            // Now we have correct blockViewModels

            self.pageDetailsViewModels = [
                .title : titleBlockModel,
                .iconEmoji : emojiBlockModel
            ]

            self.wholePageDetailsViewModel.receive(details: information)
            // Send event that we are ready.
        }
    }
}

// MARK: - Cleanup
extension Namespace.ViewModel {
    func close() {
        self.closePage()
    }
}

private extension Namespace.ViewModel {
    // It is called automatically ( should be called automatically ) by publisher
    
    func closePage() {
        self.shouldClosePagePublisher.send(true)
    }
    
    func cleanupSubscriptions() {
        self.subscriptions.cancelAll()
    }
}

// MARK: - On Tap Gesture
extension Namespace.ViewModel {
    func handlingTapIfEmpty() {
        var model: BlockActiveRecordModelProtocol?
        if let rootId = self.rootModel?.rootId, let blockModel = self.rootModel?.blocksContainer.choose(by: rootId) {
            model = blockModel
        }
        self.userInteractionHandler.createEmptyBlock(listIsEmpty: self.state == .empty, parentModel: model)
    }
}

// MARK: didSelectItem
extension Namespace.ViewModel {
    
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
private extension Namespace.ViewModel {
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
//            self.syncBuilders()
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
//                    self.syncBuilders()
                case .deselectAll:
                    self.deselectAll()
//                    self.syncBuilders()
                }
            case .done(.done):
                self.set(selectionEnabled: false)
//                self.syncBuilders()
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

extension Namespace.ViewModel {
    enum ActionsPayload {
        typealias BlockId = TopLevel.AliasesMap.BlockId
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

extension Namespace.ViewModel {
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
extension Namespace.ViewModel: CustomDebugStringConvertible {
    var debugDescription: String {
        "\(String(reflecting: Self.self)) -> \(self.debugDocumentId)"
    }
}

// MARK: Enhance UserActions and Payloads
/// These methods work in opposite way as `Merging`.
/// Instead, we just set a "delegate" ( no, our Subject ) to all viewModels in a List.
/// So, we have different approach.
///
/// 1. We have one Subject that we give to all ViewModels.
///
extension Namespace.ViewModel {
    func enhanceUserActionsAndPayloads(_ builders: [BlockViewBuilderProtocol]) {
        let ourViewModels = builders.compactMap({$0 as? BlocksViewsNamespace.Base.ViewModel})
        
        _ = ourViewModels.map({$0.configured(userActionSubject: self.publicUserActionSubject)})
        
        _ = ourViewModels.map({$0.configured(actionsPayloadSubject: self.publicActionsPayloadSubject)})
        
        _ = ourViewModels.map({$0.configured(sizeDidChangeSubject: self.publicSizeDidChangeSubject)})
    }
    
    func enhanceDetails(_ value: PageDetailsViewModelsDictionary) {
        _ = value.values.compactMap({$0 as? BlocksViewsNamespace.Base.ViewModel}).map({$0.configured(userActionSubject: self.publicUserActionSubject)}).map({$0.configured(actionsPayloadSubject: self.publicActionsPayloadSubject)})
    }
}

// MARK: Refresh UserActions and Payloads
/// These methods work in direct way as `Merging`.
/// If we have a list of viewModels with `Subject` or `Publisher`, we could do the following:
///
/// 1. We could `MergeMany` to gather all events in one `Publisher` on which we will react.
///
/// Unfortunately, this method doesn't work.
///
extension Namespace.ViewModel {
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
