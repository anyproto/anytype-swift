import Foundation

@MainActor
final class ChatCreateObjectCoordinatorViewModel: ObservableObject {
    
    let data: EditorScreenData
    
    init(data: EditorScreenData) {
        self.data = data
    }
    
}
