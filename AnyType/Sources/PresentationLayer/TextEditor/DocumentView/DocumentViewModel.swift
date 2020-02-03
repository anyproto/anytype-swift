//
//  DocumentViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

class DocumentViewModel: ObservableObject {
    private let documentService: DocumentServiceProtocol = TestDocumentService()
    private var documentHeader: DocumentHeader?
    
    // TODO: Probably we don't need it here, remove after midleware integration
    private var document: Document?
    
    @Published var error: String?
    @Published var builders: [BlockViewBuilderProtocol] = []
    var indexDictionary: IndexDictionary = .init()
    var internalState: State = .loading
    
    init(documentId: String?) {
        obtainDocument(documentId: documentId)
    }
    
    func addBlock(content: BlockType, afterBlock: Int) {
        guard let documentHeader = documentHeader else { return }
        
        let index = afterBlock + 1
        
        documentService.addBlock(content: content, by: index, for: documentHeader.id) { [weak self] result in
            guard let strongSelf = self else { return }

            switch result {
            case .success(let newDocumentModel):
                strongSelf.createblocksViewsBuilders(document: newDocumentModel)
            case .failure(let error):
                strongSelf.error = error.localizedDescription
            }
        }
    }
    
    func moveBlock(fromIndex: Int, toIndex: Int) {
        guard var document = document else { return }
        document.blocks.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex)
        createblocksViewsBuilders(document: document)
    }
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

// MARK: Obtain Document and Builders.
extension DocumentViewModel {
    
    private func obtainDocument(documentId: String?) {
        self.internalState = .loading
        let completion = { [weak self] (result: Result<Document, Error>) in
            guard let strongSelf = self else { return }
            
            strongSelf.internalState = .empty // not loading.
            switch result {
            case .success(let document):
                strongSelf.documentHeader = document.header
                strongSelf.createblocksViewsBuilders(document: document)
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
    
    // TODO: Refact when middle will be ready
    private func createblocksViewsBuilders(document: Document) {
        builders = BlocksViews.Supplement.BlocksSerializer.default.resolver(blocks: document.blocks)
//        builders.flatMap{ self.indexDictionary.update($0.compactMap{$0.id}) }
        self.indexDictionary.update(builders.map{$0.id})
        _ = builders.compactMap{$0 as? TextBlocksViews.Base.BlockViewModel}.compactMap{$0.configure(self)}
    }
    
}
