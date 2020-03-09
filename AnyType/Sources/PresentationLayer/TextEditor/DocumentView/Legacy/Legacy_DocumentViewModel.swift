//
//  DocumentViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation
import Combine
import os

class Legacy_DocumentViewModel: ObservableObject, BlockViewBuildersProtocolHolder {
    private let documentService: DocumentServiceProtocol = TestDocumentService()
    private var documentHeader: DocumentHeader?
    
    // TODO: Probably we don't need it here, remove after midleware integration
    private var document: Document?
    
    @Published var error: String?
    @Published var builders: [BlockViewBuilderProtocol] = [] {
        didSet {
            // On each update we rebuild indexDictionary.
            // It is incorrect logic.
            self.enhance(self.builders)
        }
    }
    
    var textViewUserInteractor: BlocksViews.Base.Utilities.TextBlocksUserInteractor<Legacy_DocumentViewModel>?
    var internalState: State = .loading
    
    
    init(documentId: String?) {
        self.textViewUserInteractor = .init(self)
//        obtainDocument(documentId: documentId)
    }
    
    func textViewUserInteractionDelegate() -> TextBlocksViewsUserInteractionProtocol? {
        self.textViewUserInteractor
    }
    
    // TODO: Refact when middle will be ready
    func processBlocks(models: [Document.Element]) -> [BlockViewBuilderProtocol] {
        BlocksViews.Supplement.BlocksSerializer.default.resolver(blocks: models)
    }
    
    func createBlocksViewsBuilders(document: Document) {
        self.update(builders: self.processBlocks(models: document.blocks))
    }
    
    // MARK: Redraw purposes.
    func update(builders: [BlockViewBuilderProtocol]) {
        self.textViewUserInteractor?.updater.update(builders: builders)
    }
    
    // MARK: Obtain document.
    func obtainDocument(documentId: String?) {
        self.internalState = .loading
        let completion = { [weak self] (result: Result<Document, Error>) in
            guard let strongSelf = self else { return }
            
            strongSelf.internalState = .empty // not loading.
            switch result {
            case .success(let document):
                strongSelf.documentHeader = document.header
                strongSelf.createBlocksViewsBuilders(document: document)
                strongSelf.document = document
            case .failure(let error):
                strongSelf.error = error.localizedDescription
            }
        }
        
        /// if document exists obtain it or create new one
        if let documentId = documentId {
            documentService.obtainDocument(id: documentId, completion: completion)
        } else {
            documentService.createNewDocument(completion: completion)
        }
    }
}

// MARK:
extension Legacy_DocumentViewModel {
    func addBlock(content: BlockType, afterBlock: Int) {
        guard let documentHeader = documentHeader else { return }
        
        let index = afterBlock + 1
        
        documentService.addBlock(content: content, by: index, for: documentHeader.id) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let newDocumentModel):
                strongSelf.createBlocksViewsBuilders(document: newDocumentModel)
            case .failure(let error):
                strongSelf.error = error.localizedDescription
            }
        }
    }
    
    func moveBlock(fromIndex: Int, toIndex: Int) {
        guard var document = document else { return }
        document.blocks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
        createBlocksViewsBuilders(document: document)
    }
}

// MARK: State
extension Legacy_DocumentViewModel {
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

// MARK: Builders Enchantements
extension Legacy_DocumentViewModel {
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
