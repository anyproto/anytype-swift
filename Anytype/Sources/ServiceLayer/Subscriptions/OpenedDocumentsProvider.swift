import Foundation

protocol OpenedDocumentsProviderProtocol: AnyObject {
    func document(objectId: String, forPreview: Bool) -> BaseDocumentProtocol
    func setDocument(objectId: String, forPreview: Bool) -> SetDocumentProtocol
}

// Default arguments
extension OpenedDocumentsProviderProtocol {
    func document(objectId: String) -> BaseDocumentProtocol {
        return document(objectId: objectId, forPreview: false)
    }
    func setDocument(objectId: String) -> SetDocumentProtocol {
        return setDocument(objectId: objectId, forPreview: false)
    }
}

final class OpenedDocumentsProvider: OpenedDocumentsProviderProtocol {
    // MARK: - DI
    @Injected(\.documentsProvider)
    private var documentsProvider: DocumentsProviderProtocol
    
    // MARK: - DocumentServiceProtocol
    func document(objectId: String, forPreview: Bool) -> BaseDocumentProtocol {
        let document = documentsProvider.document(objectId: objectId, forPreview: forPreview)
        
        Task { @MainActor in
            if forPreview {
                try await document.openForPreview()
            } else {
                try await document.open()
            }
        }
        
        return document
    }
    
    func setDocument(objectId: String, forPreview: Bool) -> SetDocumentProtocol {
        let document = documentsProvider.setDocument(
            objectId: objectId,
            forPreview: forPreview,
            inlineParameters: nil
        )
        
        Task { @MainActor in
            if forPreview {
                try await document.openForPreview()
            } else {
                try await document.open()
            }
        }
        
        return document
    }
}
