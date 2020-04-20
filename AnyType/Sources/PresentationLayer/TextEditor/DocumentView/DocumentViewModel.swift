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

class DocumentViewModel: ObservableObject, Legacy_BlockViewBuildersProtocolHolder {
    typealias RootModel = BlockModels.Block.RealBlock
    
    private var blockActionsService: BlockActionsService = .init()
    private var subscriptions: Set<AnyCancellable> = .init()
    
    private var transformer: BlockModels.Transformer.FinalTransformer = .init()
    private var flattener: BlocksViews.Supplement.BlocksFlattener = .init()
    
    private var treeTextViewUserInteractor: BlocksViews.Supplement.TreeTextBlocksUserInteractor<DocumentViewModel>?
    
    /// Structure contains `Feature Flags`.
    ///
    struct Options {
        var shouldCreateEmptyBlockOnTapIfListIsEmpty: Bool = false
    }
    
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
        }
    }
    
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
        }
    }
    
    var anyFieldPublisher: AnyPublisher<String, Never> = .empty()
    var fileFieldPublisher: AnyPublisher<FileBlocksViews.Base.BlockViewModel.State?, Never> = .empty()
    // put into protocol?
    // var userActionsPublisher: AnyPublisher<UserAction>
    
    // MARK: Lifecycle
    
    init(documentId: String?, options: Options) {
        // TODO: Add failable init.
        let logger = Logging.createLogger(category: .treeViewModel)
        os_log(.debug, log: logger, "Don't forget to change to failable init?() .")
        
        guard let documentId = documentId else { return }
        
        self.options = options

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
            if self?.internalState != .ready {
                self?.processBlocks(contextId: documentId, rootId: value.rootId, models: value.blocks)
                self?.internalState = .ready
            }
        }.store(in: &self.subscriptions)
//
        // We are waiting for value "true" to send `.blockClose()` with parameters "contextID: documentId, blockID: documentId"
        self.shouldClosePagePublisher.drop(while: {$0 == false}).flatMap { [weak self] (value) in
            self?.blockActionsService.close.action(contextID: documentId, blockID: documentId) ?? .empty()
        }.sink(receiveCompletion: { [weak self] (value) in
            self?.cleanupSubscriptions()
        }, receiveValue: {_ in }).store(in: &self.subscriptions)

        self.obtainDocument(documentId: documentId)
        
        // some more

        self.rootModel?.objectWillChange.sink { [weak self] (value) in
            self?.syncBuilders()
        }.store(in: &self.subscriptions)

        self.$builders.sink { [weak self] value in
            self?.buildersRows = value.compactMap(Row.init)
        }.store(in: &self.subscriptions)

        self.anyFieldPublisher = self.$builders
            .map {
                $0.compactMap { $0 as? TextBlocksViews.Base.BlockViewModel }
        }
        .flatMap {
            Publishers.MergeMany($0.map{$0.$text})
        }
        .eraseToAnyPublisher()
        
        self.fileFieldPublisher = self.$builders
            .map {
                $0.compactMap { $0 as? FileBlocksViews.Base.BlockViewModel }
        }.flatMap {
            Publishers.MergeMany($0.map{$0.$state})
        }.eraseToAnyPublisher()
    }
    
    private func textViewUserInteractionDelegate() -> TextBlocksViewsUserInteractionProtocol? {
        self.treeTextViewUserInteractor
    }
    
    /// Update @Published $builders.
    private func syncBuilders() {
        self.rootModel.flatMap(toList(_:)).flatMap(update(builders:))
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
    
    private func obtainDocument(documentId: String?) {
        guard let documentId = documentId else { return }
        self.internalState = .loading
        
        self.blockActionsService.open.action(contextID: documentId, blockID: documentId)
            .print()
            .sink(receiveCompletion: { [weak self] (value) in
                switch value {
                case .finished: break
                case let .failure(error):
                    self?.internalState = .empty
                    self?.error = error.localizedDescription
                }
            }, receiveValue: {_ in }).store(in: &self.subscriptions)
    }
}

// MARK: Find Block
private extension DocumentViewModel {
    func find(by blockId: String) -> BlocksViews.Base.ViewModel? {
        self.buildersRows.first { (row) in
            row.builder.blockId == blockId
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
        var builder: BlockViewBuilderProtocol
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
        lhs.builder.blockId == rhs.builder.blockId
    }
    
    func hash(into hasher: inout Hasher) {
//        hasher.combine(self.builder.id)
        hasher.combine(self.builder.blockId)
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
