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
            DocumentHeader(id: "1", name: "Get started", version: "1", icon: "👋"),
            DocumentHeader(id: "2", name: "Ideas", version: "1", icon: "💡"),
            DocumentHeader(id: "3", name: "Projects", version: "1", icon: "🔭"),
            DocumentHeader(id: "4", name: "Archive", version: "1", icon: "🗑"),
        ]
        let documentsModel = Documents(currentDocumentId: "", documents: documents)
        completion(Result.success(documentsModel))
    }
    
    func obtainDocument(id: String, completion: (Result<Documents.Document, Error>) -> Void) {
        let header = DocumentHeader(id: "1", name: "Ideas", version: "1", icon: "💡")
        let blocks = [
            Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text)))
        ]
        let documentModel = Documents.Document(header: header, blocks: blocks)
        completion(Result.success(documentModel))
    }
    
    func createNewDocument(completion: (Result<Documents.Document, Error>) -> Void) {
        let header = DocumentHeader(id: "1", name: "Untitled", version: "1", icon: "📄")
        let documentModel = Documents.Document(header: header, blocks: [])
        completion(Result.success(documentModel))
    }
    
    func addBlock(content: BlockType, by index: Int, for document: Documents.Document, completion: (Result<Documents.Document, Error>) -> Void) {
        let block = Block(id: "1", parentId: "", type: content)
        var documentModel = document
        documentModel.blocks.insert(block, at: index)
        
        completion(Result.success(documentModel))
    }
    
}
