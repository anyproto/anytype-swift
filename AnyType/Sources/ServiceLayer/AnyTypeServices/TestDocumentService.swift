//
//  TestDocumentService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

class TestDocumentService: DocumentServiceProtocol {
    
    func obtainDocuments(completion: (Result<Documents, Error>) -> Void) {
        let documents = [
            DocumentHeader(name: "Get started", icon: "👋"),
            DocumentHeader(name: "Ideas", icon: "💡"),
            DocumentHeader(name: "Projects", icon: "🔭"),
            DocumentHeader(name: "Archive", icon: "🗑"),
        ]
        let documentsModel = Documents(currentDocumentId: "", documents: documents)
        completion(Result.success(documentsModel))
    }
    
    func obtainDocument(id: String, completion: (Result<Document, Error>) -> Void) {
        let header = DocumentHeader(name: "Ideas", icon: "💡")
        let blocks = [
            Block(id: "1", parentId: "2", type: .text(TextContent(text: "some string")))
        ]
        let documentModel = Document(header: header, blocks: blocks)
        completion(Result.success(documentModel))
    }
}
