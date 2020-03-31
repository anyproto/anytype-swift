//
//  TestDocumentService.swift
//  AnyType
//
//  Created by Denis Batvinkin on 13.09.2019.
//  Copyright © 2019 AnyType. All rights reserved.
//

#warning("DeveloperMessages.FileIsDeprecated")

import Foundation
import SwiftUI

class TestDocumentService: DocumentServiceProtocol {
    typealias Model = BlockModels.Block.RealBlock
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
        
        private enum BlocksSet: String {
            case debug
            case focus
            case presentation
            case small
            static func debugSet() -> [Model] {
                
                [
                    .mockText(.text),
                    .mockText(.header),
                    .mockText(.text),
                    .mockText(.text),
                    .mockText(.todo),
                    .mockText(.todo),
                    .mockText(.todo),
                    .mockText(.bulleted),
                    .mockText(.bulleted),
                    .mockText(.bulleted),
                    .mockText(.numbered),
                    .mockText(.numbered),
                    .mockText(.numbered),
                    .mockText(.quote),
                    .mockText(.numbered),
                    .mockText(.text),
                    .mockText(.toggle),
                    .mockText(.callout),
                    .mockImage(.image),
                    .mockImage(.image)
                ]
            }
            static func smallSet() -> [Model] {
                [
                    .mockText(.bulleted),
                    .mockText(.numbered),
                    .mockText(.numbered),
                    .mockText(.numbered),
                    .mockText(.bulleted),
                ]
            }
            static func focusSet() -> [Model] {
                [
                    .mockText(.bulleted),
                    .mockText(.quote),
                    .mockText(.todo),
                ]
            }
            static func presentationSet() -> [Model] {
                [
                    .mockImage(.pageIcon),
                    .mockText(.header),
                    .mockText(.text),
                    .mockText(.todo),
                    .mockText(.todo),
                    .mockText(.todo),
                    .mockText(.bulleted),
                    .mockText(.bulleted),
                    .mockText(.bulleted),
                    .mockText(.numbered),
                    .mockText(.numbered),
                    .mockText(.numbered),
                    .mockText(.quote),
                    .mockText(.toggle),
                    .mockText(.callout),
                ]
            }
            func blocks() -> [Model] {
                switch self {
                case .debug: return Self.debugSet()
                case .focus: return Self.focusSet()
                case .presentation: return Self.presentationSet()
                case .small: return Self.smallSet()
                }
            }
        }
        private static func getBlocks(set: BlocksSet) -> [Model] {
            set.blocks()
        }
        
        @Environment(\.developerOptions) private var developerOptions
        
        var blocks: [Model] = {
            Self.getBlocks(set: .small)
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
        let block = Model.init(information: .init(id: "1", content: content))
        
        if var document = testDocuments.document(id: documentId) {
            document.blocks.insert(block, at: index)
            completion(Result.success(document))
        } else {
            completion(Result.failure(DocumentServiceError.documentNotFound))
        }
    }
    
    func moveBlockList(contextId: String, blockIds: String, targetContextId: String, dropTargetId: String, position: PostionBlock) {
        guard var document = testDocuments.document(id: "1") else { return }
        
//        document.blocks.move(fromOffsets: <#T##IndexSet#>, toOffset: <#T##Int#>)
    }
    
}
