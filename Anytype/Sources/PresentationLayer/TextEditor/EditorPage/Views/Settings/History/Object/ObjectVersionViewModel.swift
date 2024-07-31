import Services
import SwiftUI

struct ObjectVersionData: Identifiable, Hashable {
    let title: String
    let objectId: String
    let versionId: String
    let isListType: Bool
    
    var id: Int { hashValue }
}

@MainActor
final class ObjectVersionViewModel: ObservableObject {
    
    @Published var screenData: EditorScreenData?
    let data: ObjectVersionData
    
    private let openDocumentProvider: OpenedDocumentsProviderProtocol = Container.shared.documentService()
    
    init(data: ObjectVersionData) {
        self.data = data
        self.screenData = currentScreenData()
    }
    
    private func currentScreenData() -> EditorScreenData? {
        if data.isListType {
            return openDocumentProvider.document(objectId: data.objectId).details?.editorScreenData()
        } else {
            return openDocumentProvider.setDocument(objectId: data.objectId).details?.editorScreenData()
        }
    }
}

