//
//  DocumentViewModel+Tree.swift
//  AnyType
//
//  Created by Dmitry Lobanov on 19.02.2020.
//  Copyright © 2020 AnyType. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import os

private extension Logging.Categories {
    static let treeViewModel: Self = "DocumentViewModel.Tree"
}

// MARK: State
extension DocumentViewModel {
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
extension DocumentViewModel {
    enum UserEvent {
        case pageDetailsViewModelsDidSet
    }
}

// MARK: - Options
extension DocumentViewModel {
    /// Structure contains `Feature Flags`.
    ///
    struct Options {
        var shouldCreateEmptyBlockOnTapIfListIsEmpty: Bool = false
    }
}

class DocumentViewModel: ObservableObject, Legacy_BlockViewBuildersProtocolHolder {
    typealias RootModel = BlockModels.Block.RealBlock

    /// Service
    private var blockActionsService: BlockActionsService = .init()
    
    /// Data Transformers
    private var transformer: BlockModels.Transformer.FinalTransformer = .init()
    private var flattener: BlocksViews.Supplement.BlocksFlattener = .init()
    
    /// User Interaction Processor
    private var treeTextViewUserInteractor: BlocksViews.Supplement.TreeTextBlocksUserInteractor<DocumentViewModel>?
    
    /// Combine Subscriptions
    private var subscriptions: Set<AnyCancellable> = .init()

    /// Builders Publisher
    private lazy var buildersPublisherSubject: PassthroughSubject<AnyPublisher<BlocksViews.UserAction, Never>, Never> = .init()
    private lazy var detailsPublisherSubject: PassthroughSubject<AnyPublisher<BlocksViews.UserAction, Never>, Never> = .init()
    lazy var userActionPublisher: AnyPublisher<AnyPublisher<BlocksViews.UserAction, Never>, Never> = {
        Publishers.Merge(self.buildersPublisherSubject, self.detailsPublisherSubject).eraseToAnyPublisher()
    }()
        
    /// Options property publisher.
    /// We expect that `ViewController` will listen this property.
    /// `ViewController` should sink on this property after `viewDidLoad`.
    ///
    @Published var options: Options = .init()
    
    @Published var error: String?
    @Published var rootViewModel: BlocksViews.Base.ViewModel?
    @Published var rootModel: RootModel? {
        didSet {
            self.syncBuilders()
            self.configurePageDetails(for: self.rootModel)
            if let model = self.rootModel {
                model.objectWillChange.sink { [weak self] (value) in
                    self?.syncBuilders()
                }.store(in: &self.subscriptions)
            }
        }
    }
    
    // MARK: - Events
    @Published var userEvent: UserEvent?
    
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
    @Published var builders: [BlockViewBuilderProtocol] = [] {
        didSet {
            // On each update we rebuild indexDictionary.
            // It is incorrect logic.
            self.enhance(self.builders)
        }
    }

    private var shouldClosePagePublisher: CurrentValueSubject<Bool, Error> = .init(false)
    private var internalState: State = .loading
        
    @Published var buildersRows: [Row] = [] {
        didSet {
            self.objectWillChange.send()
            
            let value = self.$buildersRows.map {
                $0.compactMap({$0.builder as? BlocksViews.Base.ViewModel})
            }
            .flatMap({
                Publishers.MergeMany($0.map(\.userActionPublisher))
            }).eraseToAnyPublisher()
            self.buildersPublisherSubject.send(value)
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
        
        self.options = options
        _ = self.wholePageDetailsViewModel.configured(documentId: documentId)
        
        // Publishers
        
        self.treeTextViewUserInteractor?.$reaction.filter({ (value) in
            switch value {
            case .unknown: return false
            default: return true
            }
        }).sink(receiveValue: { [weak self] (value) in
            self?.process(reaction: value)
        }).store(in: &self.subscriptions)

        self.blockActionsService.eventListener.receive(contextId: documentId).sink { [weak self] (value) in
            self?.internalProcessBlocks(contextId: documentId, rootId: value.rootId, models: value.blocks)
        }.store(in: &self.subscriptions)

        // We are waiting for value "true" to send `.blockClose()` with parameters "contextID: documentId, blockID: documentId"
        self.shouldClosePagePublisher.drop(while: {$0 == false}).flatMap { [weak self] (value) -> AnyPublisher<Never, Error> in
            self?.cleanupSubscriptions()
            return BlockActionsService.Close().action(contextID: documentId, blockID: documentId).eraseToAnyPublisher()
        }.sink(receiveCompletion: { [weak self] (value) in
//            self?.cleanupSubscriptions()
        }, receiveValue: {_ in }).store(in: &self.subscriptions)

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
        
    // MARK: Private methods
    
    private func textViewUserInteractionDelegate() -> TextBlocksViewsUserInteractionProtocol? {
        self.treeTextViewUserInteractor
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
        let result = flattener.toList(model)
        let logger = Logging.createLogger(category: .treeViewModel)
        os_log(.debug, log: logger, "model: %@", model.debugDescription)
        return result
    }
    
    /// Process blocks list when we receive it from event BlockShow.
    /// - Parameters:
    ///   - contextId: an Identifier of context in which we are working. It is equal to documentId.
    ///   - rootId: an Identifier of root block. It is equal to top-most `Page Identifier`.
    ///   - models: models is a `List` of Middleware objects ( actually, our model objects ) that we would like to process.
    private func processBlocks(contextId: String? = nil, rootId: String? = nil, models: [MiddlewareBlockInformationModel]) {
        // create metablock.
        let baseModel = self.transformer.transform(models.map({BlockModels.Block.Information.init(information: $0)}), rootId: rootId)
        let model = baseModel
        self.rootViewModel = .init(model)
        self.treeTextViewUserInteractor = .init(self)
        _ = self.treeTextViewUserInteractor?.configured(documentId: contextId).configured(finder: BlockModels.Finder(value: model))
        self.rootModel = baseModel
    }
    
    private func internalProcessBlocks(contextId: String? = nil, rootId: String? = nil, models: [MiddlewareBlockInformationModel]) {
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

// MARK: Find Block
private extension DocumentViewModel {
    func find(by blockId: String) -> BlocksViews.Base.ViewModel? {
        self.buildersRows.first { (row) in
            row.builder?.blockId == blockId
        }.map(\.builder).flatMap{$0 as? BlocksViews.Base.ViewModel}
    }
}

// MARK: Reactions
private extension DocumentViewModel {
    func process(reaction: BlocksViews.Supplement.TreeTextBlocksUserInteractor<DocumentViewModel>.Reaction) {
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
            
        default:
            return
        }
    }
}

// MARK: - PageDetails
private extension DocumentViewModel {
    func configurePageDetails(for rootModel: RootModel?) {
        guard let model = rootModel else { return }
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
        let information = model.information
        let title = information.details.title
        let emoji = information.details.iconEmoji
            
        /// Title Model
        let titleBlock = BlockModels.Block.Information.DetailsAsBlockConverter(information: information)(.title(title ?? .init(text: "")))
        let titleBlockModel = PageBlocksViews.Title.BlockViewModel.init(titleBlock).configured(pageDetailsViewModel: self.wholePageDetailsViewModel)
        
        /// Emoji Model
        let emojiBlock = BlockModels.Block.Information.DetailsAsBlockConverter(information: information)(.iconEmoji(emoji ?? .init(text: "")))

        let emojiBlockModel = PageBlocksViews.IconEmoji.BlockViewModel.init(emojiBlock).configured(pageDetailsViewModel: self.wholePageDetailsViewModel)
      
        
        // Now we have correct blockViewModels
        let models = [BlockModels.Block.Information.Details.Kind.iconEmoji : emojiBlockModel, BlockModels.Block.Information.Details.Kind.title : titleBlockModel]
        
        self.pageDetailsViewModels = models
   
        self.wholePageDetailsViewModel.receive(details: information.details)
        // Send event that we are ready.        
    }
}

// MARK: - Builders Enchantements
private extension DocumentViewModel {
    func enhance(_ builder: BlockViewBuilderProtocol) {
        _ = (builder as? TextBlocksViewsUserInteractionProtocolHolder)
            .flatMap{
                $0.configured(self.textViewUserInteractionDelegate())
            }
    }
    
    func enhance(_ builders: [BlockViewBuilderProtocol]) {
        _ = builders.compactMap(self.enhance)
    }
}

// MARK: - Cleanup
extension DocumentViewModel {
    func close() {
        self.closePage()
    }
}

private extension DocumentViewModel {
    // It is called automatically ( should be called automatically ) by publisher
    
    func closePage() {
        self.shouldClosePagePublisher.send(true)
    }
    
    func cleanupSubscriptions() {
        self.subscriptions.cancelAll()
    }
}

// MARK: - On Tap Gesture
extension DocumentViewModel {
    func handlingTapIfEmpty() {
        self.treeTextViewUserInteractor?.createEmptyBlock(listIsEmpty: self.state == .empty)
    }
}

// MARK: - BlocksViewsViewModelHolder
// TODO: Rethink this protocol. Possibly we don't need it.
extension DocumentViewModel: BlocksViewsViewModelHolder {
    var ourViewModel: BlocksViews.Base.ViewModel {
        rootViewModel!
    }
}

// MARK: - TableViewModelProtocol
extension DocumentViewModel: TableViewModelProtocol {
    func numberOfSections() -> Int {
        1
    }
    
    func countOfElements(at: Int) -> Int {
        self.builders.count
    }
    
    func section(at: Int) -> DocumentViewModel.Section {
        .init()
    }
    
    func element(at: IndexPath) -> DocumentViewModel.Row {
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
extension DocumentViewModel.Section: Hashable {}

// MARK: - TableViewModelProtocol.Row
extension DocumentViewModel.Row: Hashable, Equatable {
    
    static func == (lhs: DocumentViewModel.Row, rhs: DocumentViewModel.Row) -> Bool {
//        lhs.builder.id == rhs.builder.id
        lhs.builder?.blockId == rhs.builder?.blockId
    }
    
    func hash(into hasher: inout Hasher) {
//        hasher.combine(self.builder.id)
        hasher.combine(self.builder?.blockId)
    }
}

// MARK: didSelectItem
extension DocumentViewModel {
    
    func didSelectBlock(at index: IndexPath) {
        let item = element(at: index)
        // dispatch event
        if let builder = item.builder as? BlocksViews.Base.ViewModel {
            builder.receive(event: .didSelectRowInTableView)
        }
    }
    
}
