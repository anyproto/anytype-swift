//
//  DocumentViewModel.swift
//  AnyType
//
//  Created by Denis Batvinkin on 19.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

class DocumentViewModel: ObservableObject {
    private let documentService = TestDocumentService()
    
    @Published var documentModel: Document?
    @Published var error: String?
    
    init(documentId: String?) {
        obtainDocument(documentId: documentId)
    }
    
    func addBlock(content: Content) {
        documentService.addBlock(content: content, by: <#T##Int#>, for: <#T##Document#>, completion: <#T##(Result<Document, Error>) -> Void#>)
    }
}
 
extension DocumentViewModel {
    
    private func obtainDocument(documentId: String?) {
        let completion = { [weak self] (result: Result<Document, Error>) in
            guard let strongSelf = self else { return }
            
            switch result {
            case .success(let document):
                strongSelf.documentModel = document
            case .failure(let error):
                strongSelf.error = error.localizedDescription
            }
        }
        
        if let documentId = documentId {
            documentService.obtainDocument(id: documentId, completion: completion)
        } else {
            documentService.createNewDocument(completion: completion)
        }
    }
}
