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

class DocumentViewModelTreeViewModel: DocumentViewModel {
    private var blockActionsService: BlockActionsService = .init()
    private var subscriptions: Set<AnyCancellable> = .init()
    
    typealias RootModel = BlockModels.Block.RealBlock
    
    var transformer: BlockModels.Transformer.FinalTransformer = .init()
    var updater: BlockModels.Updater<RootModel>?
    var flattener: BlocksViews.Supplement.BlocksFlattener = .init()
    var treeTextViewUserInteractor: BlocksViews.Base.Utilities.TreeTextBlocksUserInteractor<DocumentViewModelTreeViewModel>?
    
    @Published var rootViewModel: BlocksViews.Base.ViewModel?
    @Published var rootModel: RootModel? {
        didSet {
            self.syncBuilders()
        }
    }
    
    var shouldClosePagePublisher: CurrentValueSubject<Bool, Error> = .init(false)
    
    override func textViewUserInteractionDelegate() -> TextBlocksViewsUserInteractionProtocol? { self.treeTextViewUserInteractor }
    
    func syncBuilders() {
        self.rootModel.flatMap({update(builders: toList($0))})
    }
    
    func toList(_ model: RootModel) -> [BlockViewBuilderProtocol] {
        let result = flattener.toList(model)
        let logger = Logging.createLogger(category: .treeViewModel)
        os_log(.debug, log: logger, "model: %@", model.debugDescription)
        return result
    }
    
    override init(documentId: String?) {
        super.init(documentId: documentId)
        guard let documentId = documentId else { return }
        
        self.blockActionsService.eventListener.receive(contextId: documentId).sink { [weak self] (value) in
            if self?.internalState != .ready {
                _ = self?.processBlocks(value.rootId, value.blocks)
                self?.internalState = .ready
            }
        }.store(in: &self.subscriptions)
        
        // We are waiting for value "true" to send `.blockClose()` with parameters "contextID: documentId, blockID: documentId"
        self.shouldClosePagePublisher.drop(while: {$0 == false}).flatMap { [weak self] (value) in
            self?.blockActionsService.close.action(contextID: documentId, blockID: documentId) ?? .empty()
        }.sink(receiveCompletion: { [weak self] (value) in
            switch value {
            case .finished:
                self?.cleanupSubscriptions()
                break
            case .failure:
                self?.cleanupSubscriptions()
                break
            }
            }, receiveValue: {_ in }).store(in: &self.subscriptions)
        
        self.obtainDocument(documentId: documentId)
    }
    
    func processBlocks(_ rootId: String? = nil, _ models: [MiddlewareBlockInformationModel]) -> [BlockViewBuilderProtocol] {
        // create metablock.
        let baseModel = self.transformer.transform(models.map({BlockModels.Block.Information.init(information: $0)}), rootId: rootId)
        let model = baseModel
        self.rootViewModel = .init(model)
        self.updater = .init(value: model)
        self.treeTextViewUserInteractor = .init(self)
        self.rootModel = baseModel
        self.rootModel?.objectWillChange.sink { [weak self] (value) in
            self?.syncBuilders()
        }.store(in: &self.subscriptions)
        return self.builders
    }
    
    override func processBlocks(models: [Document.Element]) -> [BlockViewBuilderProtocol] {
        processBlocks(nil, models.map{$0.information})
    }
    
    override func obtainDocument(documentId: String?) {
        guard let documentId = documentId else { return }
        self.internalState = .loading
        self.blockActionsService.open.action(contextID: documentId, blockID: documentId).print().sink(receiveCompletion: { [weak self] (value) in
            switch value {
            case .finished: break
            case let .failure(error):
                self?.internalState = .empty
                self?.error = error.localizedDescription
            }
            }, receiveValue: {_ in }).store(in: &self.subscriptions)
    }
}

// MARK: Cleanup
extension DocumentViewModelTreeViewModel {
    // It is called automatically ( should be called automatically ) by publisher
    //
    func closePage() {
        self.shouldClosePagePublisher.send(true)
    }
    func cleanupSubscriptions() {
        self.subscriptions.cancelAll()
    }
}

extension DocumentViewModelTreeViewModel: BlocksViewsViewModelHolder {
    var ourViewModel: BlocksViews.Base.ViewModel {
        rootViewModel!
    }
}
