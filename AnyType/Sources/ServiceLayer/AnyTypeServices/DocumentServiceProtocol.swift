//
//  DocumentServiceProtocol.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

import Foundation

/// Service for managing documents in workspace
protocol DocumentServiceProtocol {
    typealias CompletionWithDocumentsListResult = (_ resutl: Result<Documents, Error>) -> Void
    typealias CompletionWithDocumentResult = (_ resutl: Result<Document, Error>) -> Void
    
    /// Obtain documents list in workspace
    /// - Parameter completion: called on completion
    func obtainDocuments(completion: CompletionWithDocumentsListResult)
    
    /// Obtain document and its blocks
    /// - Parameter id: Document id
    /// - Parameter completion: called on completion with document list
    func obtainDocument(id: String, completion: CompletionWithDocumentResult)
    
    /// Create new document
    /// - Parameter completion: called on completion with document information
    func createNewDocument(completion: CompletionWithDocumentResult)
    
    /// Add new block to docoument
    /// - Parameter content: Block type
    /// - Parameter completion: called on completion with document information
    /// - Parameter index: block index
    /// - Parameter document: document with new block
    func addBlock(content: Content, by index: Int, for document: Document, completion: CompletionWithDocumentResult)
}
