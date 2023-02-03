import Foundation

protocol DocumentServiceProtocol: AnyObject {
    func getDocument(objectId: String) -> BaseDocumentProtocol
}

final class DocumentService: DocumentServiceProtocol {
    
    private var cache = NSMapTable<NSString, AnyObject>.strongToWeakObjects()
    
    func getDocument(objectId: String) -> BaseDocumentProtocol {
        if let value = cache.value(forKey: objectId) as? BaseDocumentProtocol {
            return value
        }
        
        let document = BaseDocument(objectId: objectId)
        Task { @MainActor in
            try? await document.open()
        }
        return document
    }
}
