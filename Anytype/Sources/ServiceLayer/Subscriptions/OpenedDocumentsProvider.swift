import Foundation

protocol OpenedDocumentsProviderProtocol: AnyObject {
    func document(objectId: String, mode: DocumentMode) -> any BaseDocumentProtocol
    func setDocument(objectId: String, mode: DocumentMode) -> any SetDocumentProtocol
}

// Default arguments
extension OpenedDocumentsProviderProtocol {
    
    func document(objectId: String) -> any BaseDocumentProtocol {
        return document(objectId: objectId, mode: .handling)
    }
    
    func setDocument(objectId: String) -> any SetDocumentProtocol {
        return setDocument(objectId: objectId, mode: .handling)
    }
}

final class OpenedDocumentsProvider: OpenedDocumentsProviderProtocol {
    // MARK: - DI
    @Injected(\.documentsProvider)
    private var documentsProvider: any DocumentsProviderProtocol
    
    // MARK: - DocumentServiceProtocol
    func document(objectId: String, mode: DocumentMode) -> any BaseDocumentProtocol {
        let document = documentsProvider.document(objectId: objectId, mode: mode)
        
        Task { @MainActor in
            try await document.open()
        }
        
        return document
    }
    
    func setDocument(objectId: String, mode: DocumentMode) -> any SetDocumentProtocol {
        let document = documentsProvider.setDocument(
            objectId: objectId,
            mode: mode
        )
        
        Task { @MainActor in
            try await document.open()
        }
        
        return document
    }
}
