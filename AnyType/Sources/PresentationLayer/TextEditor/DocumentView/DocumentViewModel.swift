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

class DocumentViewModel: ObservableObject, BlockViewBuildersProtocolHolder {
    typealias RootModel = BlockModels.Block.RealBlock
    
    private var blockActionsService: BlockActionsService = .init()
    private var subscriptions: Set<AnyCancellable> = .init()
    
    private var transformer: BlockModels.Transformer.FinalTransformer = .init()
    private var flattener: BlocksViews.Supplement.BlocksFlattener = .init()
    
    private var treeTextViewUserInteractor: BlocksViews.Base.Utilities.TreeTextBlocksUserInteractor<DocumentViewModel>?
    
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
    
    // MARK: Lifecycle
    
    init(documentId: String?, options: Options) {
        // TODO: Add failable init.
        let logger = Logging.createLogger(category: .treeViewModel)
        os_log(.debug, log: logger, "Don't forget to change to failable init?() .")
        
        guard let documentId = documentId else { return }
        
        self.options = options
        
        self.blockActionsService.eventListener.receive(contextId: documentId).sink { [weak self] (value) in
            if self?.internalState != .ready {
                _ = self?.processBlocks(contextId: documentId, rootId: value.rootId, models: value.blocks)
                self?.internalState = .ready
            }
        }.store(in: &self.subscriptions)
        
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
    }
    
    private func textViewUserInteractionDelegate() -> TextBlocksViewsUserInteractionProtocol? {
        self.treeTextViewUserInteractor
    }
    
    private func syncBuilders() {
        self.rootModel.flatMap {
            update(builders: toList($0))
        }
    }
    
    // TODO: Add caching?
    private func update(builders: [BlockViewBuilderProtocol]) {
        self.builders = builders
    }
    
    private func toList(_ model: RootModel) -> [BlockViewBuilderProtocol] {
        let result = flattener.toList(model)
        let logger = Logging.createLogger(category: .treeViewModel)
        os_log(.debug, log: logger, "model: %@", model.debugDescription)
        return result
    }
    
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

extension DocumentViewModel.Section: Hashable {}

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
