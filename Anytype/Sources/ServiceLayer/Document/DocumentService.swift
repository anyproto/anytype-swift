import Foundation

protocol DocumentServiceProtocol: AnyObject {
    func document(objectId: String, forPreview: Bool) -> BaseDocumentProtocol
    func setDocument(objectId: String, forPreview: Bool) -> SetDocumentProtocol
}

// Default arguments
extension DocumentServiceProtocol {
    func document(objectId: String) -> BaseDocumentProtocol {
        return document(objectId: objectId, forPreview: false)
    }
    func setDocument(objectId: String) -> SetDocumentProtocol {
        return setDocument(objectId: objectId, forPreview: false)
    }
}

final class DocumentService: DocumentServiceProtocol {
    
    private class CacheKey {
        let objectId: String
        let forPreview: Bool
        
        init(objectId: String, forPreview: Bool) {
            self.objectId = objectId
            self.forPreview = forPreview
        }
    }
    
    private var documentCache = NSMapTable<CacheKey, AnyObject>.strongToWeakObjects()
    private var setDocumentCache = NSMapTable<CacheKey, AnyObject>.strongToWeakObjects()
    
    private let relationDetailsStorage: RelationDetailsStorageProtocol
    
    // MARK: - DI
    
    init(relationDetailsStorage: RelationDetailsStorageProtocol) {
        self.relationDetailsStorage = relationDetailsStorage
    }
    
    // MARK: - DocumentServiceProtocol
    
    func document(objectId: String, forPreview: Bool) -> BaseDocumentProtocol {
        return internalDocument(objectId: objectId, forPreview: forPreview, open: true)
    }
    
    func setDocument(objectId: String, forPreview: Bool) -> SetDocumentProtocol {
        let key = CacheKey(objectId: objectId, forPreview: forPreview)
        if let value = setDocumentCache.object(forKey: key) as? SetDocumentProtocol {
            return value
        }
        
        let document = internalDocument(objectId: objectId, forPreview: forPreview, open: false)
        let setDocument = SetDocument(document: document, blockId: nil, targetObjectID: nil, relationDetailsStorage: relationDetailsStorage)
        
        setDocumentCache.setObject(document, forKey: key)
        
        Task { @MainActor in
            try? await forPreview ? setDocument.openForPreview() : setDocument.open()
        }
    
        return setDocument
    }
    
    // MARK: - Private func
    
    func internalDocument(objectId: String, forPreview: Bool, open: Bool) -> BaseDocumentProtocol {
        let key = CacheKey(objectId: objectId, forPreview: forPreview)
        if let value = documentCache.object(forKey: key) as? BaseDocumentProtocol {
            return value
        }
        
        let document = BaseDocument(objectId: objectId)
    
        documentCache.setObject(document, forKey: key)
        
        if open {
            Task { @MainActor in
                try? await forPreview ? document.openForPreview() : document.open()
            }
        }
        
        return document
    }
}
