import Foundation
import Services

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
    
    // MARK: DI for document
    
    private let blockActionsService: BlockActionsServiceSingleProtocol
    
    init(
        relationDetailsStorage: RelationDetailsStorageProtocol,
        objectTypeProvider: ObjectTypeProviderProtocol,
        blockActionsService: BlockActionsServiceSingleProtocol
    ) {
        self.relationDetailsStorage = relationDetailsStorage
        self.objectTypeProvider = objectTypeProvider
        self.blockActionsService = blockActionsService
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
            let document = createBaseDocument(objectId: objectId, forPreview: forPreview)
            return document
        }
        
        if let value = documentCache.object(forKey: objectId as NSString) as? BaseDocumentProtocol {
            return value
        }
        
        let document = createBaseDocument(objectId: objectId, forPreview: forPreview)
        documentCache.setObject(document, forKey: objectId as NSString)
        
        return document
    }
    
    private func createBaseDocument(objectId: String, forPreview: Bool) -> BaseDocumentProtocol {
        return BaseDocument(
            objectId: objectId,
            forPreview: forPreview,
            blockActionsService: blockActionsService,
            relationDetailsStorage: relationDetailsStorage, 
            objectTypeProvider: objectTypeProvider
        )
    }
}
