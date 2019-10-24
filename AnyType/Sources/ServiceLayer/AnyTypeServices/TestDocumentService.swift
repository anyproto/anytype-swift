//
//  TestDocumentService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

class TestDocumentService: DocumentServiceProtocol {
    
    private struct TestDocuments {
        var documentsHeaders: DocumentsHeaders = {
            let documentsHeaders = [
                DocumentHeader(id: "1", name: "Get started", version: "1", icon: "👋"),
                DocumentHeader(id: "2", name: "Ideas", version: "1", icon: "💡"),
                DocumentHeader(id: "3", name: "Projects", version: "1", icon: "🔭"),
                DocumentHeader(id: "4", name: "Archive", version: "1", icon: "🗑"),
            ]
            let documentsHeadersModel = DocumentsHeaders(currentDocumentId: "", headers: documentsHeaders)
            
            return documentsHeadersModel
        }()
        
        var blocks: [Block] = {
            return [
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "1", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text))),
                Block(id: "2", parentId: "2", type: .text(BlockType.Text(text: "1", contentType: .text)))
            ]
        }()
        
        func document(id: String) -> Document? {
            let document = documentsHeaders.headers.first { $0.id == id }.map { Document(header: $0, blocks: blocks) }
            
            return document
        }
    }
    
    private var testDocuments = TestDocuments()
    
    func obtainDocuments(completion: (Result<DocumentsHeaders, Error>) -> Void) {
        completion(Result.success(testDocuments.documentsHeaders))
    }
    
    func obtainDocument(id: String, completion: (Result<Document, Error>) -> Void) {
        if let document = testDocuments.document(id: id) {
            completion(Result.success(document))
        } else {
            completion(Result.failure(DocumentServiceError.documentNotFound))
        }
    }
    
    func createNewDocument(completion: (Result<Document, Error>) -> Void) {
        let header = DocumentHeader(id: "1", name: "Untitled", version: "1", icon: "📄")
        let documentModel = Document(header: header, blocks: [])
        testDocuments.documentsHeaders.headers.append(header)
        
        completion(Result.success(documentModel))
    }
    
    func addBlock(content: BlockType, by index: Int, for documentId: String, completion: (Result<Document, Error>) -> Void) {
        let block = Block(id: "1", parentId: "", type: content)
        
        if var document = testDocuments.document(id: documentId) {
            document.blocks.insert(block, at: index)
            completion(Result.success(document))
        } else {
            completion(Result.failure(DocumentServiceError.documentNotFound))
        }
    }
    
}
