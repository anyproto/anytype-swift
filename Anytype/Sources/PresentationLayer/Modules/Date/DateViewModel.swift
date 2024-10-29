import SwiftUI

@MainActor
final class DateViewModel: ObservableObject {
    
    // MARK: - DI
    
    private let objectId: String
    private let spaceId: String
    private let openDocumentProvider: any OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
    // MARK: - State
    
    private let document: any BaseDocumentProtocol
    
    init(objectId: String, spaceId: String) {
        self.spaceId = spaceId
        self.objectId = objectId
        self.document = openDocumentProvider.document(objectId: objectId, spaceId: spaceId)
    }
}
