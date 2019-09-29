//
//  TestDocumentService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

class TestDocumentService: DocumentServiceProtocol {
    
    func obtainDocuments(completion: (Result<Array<DocumentModel>, Error>) -> Void) {
        let documents = [
            DocumentModel(name: "Get started", emojiImage: "👋"),
            DocumentModel(name: "Ideas", emojiImage: "💡"),
            DocumentModel(name: "Projects", emojiImage: "🔭"),
            DocumentModel(name: "Archive", emojiImage: "🗑"),
        ]
        completion(Result.success(documents))
    }
    
}
