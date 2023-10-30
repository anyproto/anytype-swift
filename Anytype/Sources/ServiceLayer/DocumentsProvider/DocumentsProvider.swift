//
//  DocumentsProvider.swift
//  Anytype
//
//  Created by Dmitry Bilienko on 13.09.23.
//  Copyright © 2023 Anytype. All rights reserved.
//

import Foundation

protocol DocumentsProviderProtocol {
    func document(objectId: String, forPreview: Bool) -> BaseDocumentProtocol
    func setDocument(
        objectId: String,
        forPreview: Bool,
        inlineParameters: EditorInlineSetObject?
    ) -> SetDocumentProtocol
}

final class DocumentsProvider: DocumentsProviderProtocol {
    private var documentCache = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    private let objectTypeProvider: ObjectTypeProviderProtocol
    
    init(
        relationDetailsStorage: RelationDetailsStorageProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol
    ) {
        self.relationDetailsStorage = relationDetailsStorage
        self.objectTypeProvider = objectTypeProvider
    }
    
    func document(objectId: String, forPreview: Bool) -> BaseDocumentProtocol {
        internalDocument(objectId: objectId, forPreview: forPreview)
    }
    
    func setDocument(
        objectId: String,
        forPreview: Bool,
        inlineParameters: EditorInlineSetObject?
    ) -> SetDocumentProtocol {
        let document = internalDocument(objectId: objectId, forPreview: forPreview)
        
        return SetDocument(
            document: document,
            inlineParameters: inlineParameters,
            relationDetailsStorage: relationDetailsStorage,
            objectTypeProvider: objectTypeProvider
        )
    }
    
    // MARK: - Private
    
    private func internalDocument(objectId: String, forPreview: Bool) -> BaseDocumentProtocol {
        if forPreview {
            let document = BaseDocument(objectId: objectId, forPreview: forPreview)
            return document
        }
        
        if let value = documentCache.object(forKey: objectId as NSString) as? BaseDocumentProtocol {
            return value
        }
        
        let document = BaseDocument(objectId: objectId, forPreview: forPreview)
        documentCache.setObject(document, forKey: objectId as NSString)
        
        return document
    }
}
