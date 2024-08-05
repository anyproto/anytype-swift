import Services
import SwiftUI

struct ObjectVersionData: Identifiable, Hashable {
    let title: String
    let icon: ObjectIcon?
    let objectId: String
    let spaceId: String
    let versionId: String
    let isListType: Bool
    
    var id: Int { hashValue }
}

@MainActor
final class ObjectVersionViewModel: ObservableObject {
    
    @Published var screenData: EditorScreenData?
    let data: ObjectVersionData
    
    init(data: ObjectVersionData) {
        self.data = data
    }
    
    func setupObject() async {
        self.screenData = currentScreenData()
    }
    
    private func currentScreenData() -> EditorScreenData? {
        let mode: DocumentMode = .version(data.versionId)
        if data.isListType {
            return .set(EditorSetObject(objectId: data.objectId, spaceId: data.spaceId, mode: mode))
        } else {
            return .page(EditorPageObject(objectId: data.objectId, spaceId: data.spaceId, mode: mode))
        }
    }
}

