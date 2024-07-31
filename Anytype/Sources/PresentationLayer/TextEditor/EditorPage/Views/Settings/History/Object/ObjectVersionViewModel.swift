import Services
import SwiftUI

struct ObjectVersionData: Identifiable, Hashable {
    let title: String
    let objectId: String
    let versionId: String
    
    var id: Int { hashValue }
}

@MainActor
final class ObjectVersionViewModel: ObservableObject {
    
    let document: BaseDocumentProtocol
    let screenData: EditorScreenData?
    let data: ObjectVersionData
    
    private let openDocumentProvider: OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
    init(data: ObjectVersionData) {
        self.document = openDocumentProvider.document(objectId: data.objectId)
        self.screenData = document.details?.editorScreenData()
        self.data = data
    }
}

