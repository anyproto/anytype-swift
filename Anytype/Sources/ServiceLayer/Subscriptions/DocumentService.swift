import Foundation

protocol DocumentServiceProtocol: AnyObject {
    func document(objectId: String) -> BaseDocumentProtocol
}

final class DocumentService: DocumentServiceProtocol {
    
    private var cache = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    
    func document(objectId: String) -> BaseDocumentProtocol {
        if let value = cache.object(forKey: objectId as NSString) as? BaseDocumentProtocol {
            return value
        }
        
        let document = BaseDocument(objectId: objectId)
        Task { @MainActor in
            try? await document.open()
        }
        
        cache.setObject(document, forKey: objectId as NSString)
        
        return document
    }
}
